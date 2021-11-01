//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageAttachmentView<Factory: ViewFactory>: View {
    var factory: Factory
    var message: ChatMessage
    var contentWidth: CGFloat
    var isFirst: Bool
    
    var body: some View {
        // TODO: temporary logic
        if message.isDeleted {
            factory.makeDeletedMessageView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if !message.linkAttachments.isEmpty {
            factory.makeLinkAttachmentView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if !message.fileAttachments.isEmpty {
            factory.makeFileAttachmentView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if !message.imageAttachments.isEmpty || !message.giphyAttachments.isEmpty {
            factory.makeImageAttachmentView(
                for: message,
                isFirst: isFirst,
                availableWidth: contentWidth
            )
        } else if !message.videoAttachments.isEmpty {
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
