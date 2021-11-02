//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default implementations for the `ViewFactory`.
extension ViewFactory {
    // MARK: channels
    
    public func makeNoChannelsView() -> NoChannelsView {
        NoChannelsView()
    }
    
    public func makeLoadingView() -> LoadingView {
        LoadingView()
    }
    
    public func navigationBarDisplayMode() -> NavigationBarItem.TitleDisplayMode {
        .inline
    }
    
    public func makeChannelListHeaderViewModifier(
        title: String
    ) -> some ChannelListHeaderViewModifier {
        DefaultChannelListHeaderModifier(title: title)
    }
    
    public func suppotedMoreChannelActions(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction] {
        ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: onDismiss,
            onError: onError
        )
    }
    
    public func makeMoreChannelActionsView(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> MoreChannelActionsView {
        MoreChannelActionsView(
            channel: channel,
            channelActions: suppotedMoreChannelActions(
                for: channel,
                onDismiss: onDismiss,
                onError: onError
            ),
            onDismiss: onDismiss
        )
    }
    
    // MARK: messages
    
    public func makeChannelDestination() -> (ChatChannel) -> ChatChannelView<Self> {
        { [unowned self] channel in
            let controller = chatClient.channelController(
                for: channel.cid,
                messageOrdering: .topToBottom
            )
            return ChatChannelView(
                viewFactory: self,
                channelController: controller
            )
        }
    }
    
    public func makeMessageAvatarView(for author: ChatUser) -> MessageAvatarView {
        MessageAvatarView(author: author)
    }
    
    public func makeChannelHeaderViewModifier(
        for channel: ChatChannel
    ) -> some ChatChannelHeaderViewModifier {
        DefaultChannelHeaderModifier(channel: channel)
    }
    
    public func makeMessageTextView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> MessageTextView {
        MessageTextView(message: message, isFirst: isFirst)
    }
    
    public func makeImageAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> ImageAttachmentContainer {
        let sources = message.imageAttachments.map { attachment in
            attachment.imagePreviewURL
        }

        return ImageAttachmentContainer(
            message: message,
            sources: sources,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeGiphyAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> ImageAttachmentContainer {
        let sources = message.giphyAttachments.map { attachment in
            attachment.previewURL
        }
        
        return ImageAttachmentContainer(
            message: message,
            sources: sources,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeLinkAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> LinkAttachmentContainer {
        LinkAttachmentContainer(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeFileAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> FileAttachmentsContainer {
        FileAttachmentsContainer(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeVideoAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> VideoAttachmentsContainer {
        VideoAttachmentsContainer(
            message: message,
            width: availableWidth
        )
    }
    
    public func makeDeletedMessageView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> DeletedMessageView {
        DeletedMessageView(
            message: message,
            isFirst: isFirst
        )
    }
    
    public func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> EmptyView {
        EmptyView()
    }
    
    public func makeGiphyBadgeViewType(
        for message: ChatMessage,
        availableWidth: CGFloat
    ) -> GiphyBadgeView {
        GiphyBadgeView()
    }
}

/// Default class conforming to `ViewFactory`, used throughout the SDK.
public class DefaultViewFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = DefaultViewFactory()
}
