//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageAttachmentView: View {
    var message: ChatMessage
    var contentWidth: CGFloat
    
    var body: some View {
        // TODO: temporary logic
        if !message.imageAttachments.isEmpty {
            ImageAttachmentContainer(message: message, sources: message.imageAttachments.map { attachment in
                attachment.imagePreviewURL
            }, width: contentWidth)
        } else if !message.giphyAttachments.isEmpty {
            ImageAttachmentContainer(message: message, sources: message.giphyAttachments.map { attachment in
                attachment.previewURL
            }, width: contentWidth)
        } else if !message.videoAttachments.isEmpty {
            VideoAttachmentsContainer(message: message, width: contentWidth)
        } else {
            MessageTextView(message: message)
        }
    }
}

public struct MessageTextView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    private let cornerRadius: CGFloat = 24
    
    var message: ChatMessage
    
    public var body: some View {
        Text(message.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(backgroundColor))
            .foregroundColor(Color(colors.text))
            .font(fonts.body)
            .overlay(
                !message.isSentByCurrentUser ?
                    RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color(colors.background6),
                        lineWidth: 1
                    )
                    : nil
            )
            .cornerRadius(message.isSentByCurrentUser ? cornerRadius : 0)
    }
    
    private var backgroundColor: UIColor {
        if message.isSentByCurrentUser {
            if message.type == .ephemeral {
                return colors.background8
            } else {
                return colors.background6
            }
        } else {
            return colors.background8
        }
    }
}
