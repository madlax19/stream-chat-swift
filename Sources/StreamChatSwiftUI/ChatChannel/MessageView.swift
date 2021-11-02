//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageView<Factory: ViewFactory>: View {
    @Injected(\.utils) var utils
    
    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }
    
    var factory: Factory
    var message: ChatMessage
    var contentWidth: CGFloat
    var isFirst: Bool
    
    var body: some View {
        if messageTypeResolver.hasCustomAttachment(message: message) {
            factory.makeCustomAttachmentViewType(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if messageTypeResolver.isDeleted(message: message) {
            factory.makeDeletedMessageView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if messageTypeResolver.hasLinkAttachment(message: message) {
            factory.makeLinkAttachmentView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if messageTypeResolver.hasFileAttachment(message: message) {
            factory.makeFileAttachmentView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if messageTypeResolver.hasImageAttachment(message: message) {
            factory.makeImageAttachmentView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if messageTypeResolver.hasGiphyAttachment(message: message) {
            ZStack {
                factory.makeGiphyAttachmentView(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth
                )
                factory.makeGiphyBadgeViewType(
                    for: message,
                    availableWidth: contentWidth
                )
            }
            
        } else if messageTypeResolver.hasVideoAttachment(message: message) {
            factory.makeVideoAttachmentView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else {
            factory.makeMessageTextView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        }
    }
}

public struct MessageTextView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var message: ChatMessage
    var isFirst: Bool
    
    public var body: some View {
        Text(message.text)
            .standardPadding()
            .messageBubble(for: message, isFirst: isFirst)
            .foregroundColor(Color(colors.text))
            .font(fonts.body)
    }
}
