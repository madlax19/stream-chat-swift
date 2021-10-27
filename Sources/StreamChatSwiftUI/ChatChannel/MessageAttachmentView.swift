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
            MessageTextView(message: message, isFirst: isFirst)
        }
    }
}

public struct MessageTextView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    private let cornerRadius: CGFloat = 24
    
    var message: ChatMessage
    var isFirst: Bool
    
    public var body: some View {
        Text(message.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(backgroundColor))
            .overlay(
                BubbleBackgroundShape(cornerRadius: cornerRadius, corners: corners)
                    .stroke(
                        Color(colors.innerBorder),
                        lineWidth: 1.0
                    )
            )
            .clipShape(BubbleBackgroundShape(cornerRadius: cornerRadius, corners: corners))
            .foregroundColor(Color(colors.text))
            .font(fonts.body)
    }
    
    private var corners: UIRectCorner {
        if !isFirst {
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }
        
        if message.isSentByCurrentUser {
            return [.topLeft, .topRight, .bottomLeft]
        } else {
            return [.topLeft, .topRight, .bottomRight]
        }
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

struct BubbleBackgroundShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        return Path(path.cgPath)
    }
}
