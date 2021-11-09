//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

public class ChatChannelViewModel: ObservableObject, ChatChannelControllerDelegate {
    @Injected(\.chatClient) var chatClient
    @Injected(\.utils) var utils
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var currentDate: Date? {
        didSet {
            guard showScrollToLatestButton == true, let currentDate = currentDate else {
                currentDateString = nil
                return
            }
            currentDateString = messageListDateOverlay.string(from: currentDate)
        }
    }
    
    private let messageListDateOverlay: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMdd")
        df.locale = .autoupdatingCurrent
        return df
    }()
    
    private lazy var messagesDateFormatter = utils.dateFormatter
    
    @Atomic private var loadingPreviousMessages: Bool = false
    @Atomic private var lastMessageRead: String?
    
    var channelController: ChatChannelController
    
    @Published var scrolledId: String?

    @Published var showScrollToLatestButton = false
    @Published var currentDateString: String?
    @Published var typingUsers = [String]()
    @Published var messages = LazyCachedMapCollection<ChatMessage>() {
        didSet {
            var temp = [String: [String]]()
            for (index, message) in messages.enumerated() {
                let dateString = messagesDateFormatter.string(from: message.createdAt)
                let prefix = message.author.id
                let key = "\(prefix)-\(dateString)"
                if temp[key] == nil {
                    temp[key] = [message.id]
                } else {
                    // check if the previous message is not sent by the same user.
                    let previousIndex = index - 1
                    if previousIndex >= 0 {
                        let previous = messages[previousIndex]
                        
                        let shouldAddKey = message.author.id != previous.author.id
                        if shouldAddKey {
                            temp[key]?.append(message.id)
                        }
                    }
                }
            }
            messagesGroupingInfo = temp
        }
    }

    @Published var messagesGroupingInfo = [String: [String]]()
    
    var channel: ChatChannel {
        channelController.channel!
    }
            
    public init(channelController: ChatChannelController) {
        self.channelController = channelController
        setupChannelController()
    }
    
    func subscribeToChannelChanges() {
        channelController.messagesChangesPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            self.messages = self.channelController.messages
        }
        .store(in: &cancellables)

        if let typingEvents = channelController.channel?.config.typingEventsEnabled,
           typingEvents == true {
            subscribeToTypingChanges()
        }
    }
    
    func scrollToLastMessage() {
        if scrolledId != messages.first?.messageId {
            scrolledId = messages.first?.messageId
        }
    }
    
    func handleMessageAppear(index: Int) {
        let message = messages[index]
        checkForNewMessages(index: index)
        save(lastDate: message.createdAt)
        if index == 0 {
            maybeSendReadEvent(for: message)
        }
    }
    
    public func channelController(
        _ channelController: ChatChannelController,
        didUpdateMessages changes: [ListChange<ChatMessage>]
    ) {
        messages = channelController.messages
        
        if !showScrollToLatestButton {
            scrollToLastMessage()
        }
    }
    
    public func channelController(
        _ channelController: ChatChannelController,
        didUpdateChannel channel: EntityChange<ChatChannel>
    ) {
        messages = channelController.messages
    }
    
    // TODO: temp implementation
    func addReaction(to message: ChatMessage) {
        guard let cId = message.cid else { return }
        
        let messageController = chatClient.messageController(
            cid: cId, messageId: message.id
        )
        
        let reaction: MessageReactionType = "love"
        messageController.addReaction(reaction)
    }
    
    // MARK: - private
    
    private func setupChannelController() {
        channelController.delegate = self
        channelController.synchronize()
        messages = channelController.messages
    }
    
    private func checkForNewMessages(index: Int) {
        if index < channelController.messages.count - 10 {
            return
        }

        if _loadingPreviousMessages.compareAndSwap(old: false, new: true) {
            channelController.loadPreviousMessages(completion: { [weak self] _ in
                guard let self = self else { return }
                self.loadingPreviousMessages = false
            })
        }
    }
    
    private func save(lastDate: Date) {
        currentDate = lastDate
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false,
            block: { [weak self] _ in
                self?.currentDate = nil
            }
        )
    }
    
    private func subscribeToTypingChanges() {
        channelController.typingUsersPublisher.sink { [weak self] users in
            guard let self = self else { return }
            self.typingUsers = users.filter { user in
                user.id != self.channelController.client.currentUserId
            }.map { user in
                user.name ?? ""
            }
        }
        .store(in: &cancellables)
    }
    
    private func maybeSendReadEvent(for message: ChatMessage) {
        if message.id != lastMessageRead {
            lastMessageRead = message.id
            channelController.markRead()
        }
    }
}

extension ChatMessage: Identifiable {
    var messageId: String {
        let statesId = uploadingStatesId
        
        if statesId.isEmpty {
            if !reactionScores.isEmpty {
                return id + reactionScoresId
            } else {
                return id
            }
        }
        
        return id + statesId + reactionScoresId
    }
    
    var uploadingStatesId: String {
        var states = imageAttachments.compactMap { $0.uploadingState?.state }
        states += giphyAttachments.compactMap { $0.uploadingState?.state }
        states += videoAttachments.compactMap { $0.uploadingState?.state }
        states += fileAttachments.compactMap { $0.uploadingState?.state }
        
        if states.isEmpty {
            return ""
        }
        
        let strings = states.map { "\($0)" }
        let combined = strings.joined(separator: "-")
        let statesId = "\(id)-\(combined)"
        return statesId
    }
    
    var reactionScoresId: String {
        var output = ""
        for (key, score) in reactionScores {
            output += "\(key.rawValue)\(score)"
        }
        return output
    }
}
