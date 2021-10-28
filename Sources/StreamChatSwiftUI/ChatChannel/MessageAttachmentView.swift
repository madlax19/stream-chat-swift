//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageAttachmentView: View {
    var message: ChatMessage
    var contentWidth: CGFloat
    var isFirst: Bool
    
    var body: some View {
        // TODO: temporary logic
        if !message.fileAttachments.isEmpty {
            FileAttachmentsContainer(
                message: message,
                width: contentWidth,
                isFirst: isFirst
            )
        } else if !message.imageAttachments.isEmpty {
            ImageAttachmentContainer(message: message, sources: message.imageAttachments.map { attachment in
                attachment.imagePreviewURL
            }, width: contentWidth, isFirst: isFirst)
        } else if !message.giphyAttachments.isEmpty {
            ImageAttachmentContainer(message: message, sources: message.giphyAttachments.map { attachment in
                attachment.previewURL
            }, width: contentWidth, isFirst: isFirst)
        } else if !message.videoAttachments.isEmpty {
            VideoAttachmentsContainer(message: message, width: contentWidth)
        } else {
            MessageTextView(message: message, isFirst: isFirst)
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
