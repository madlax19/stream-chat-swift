//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Modifier that enables message bubble container.
public struct ReactionsBubbleModifier: ViewModifier {
    @Injected(\.colors) var colors
        
    var message: ChatMessage
    
    var borderColor: Color? = nil
    
    private let cornerRadius: CGFloat = 18
    
    public func body(content: Content) -> some View {
        content
            .background(Color(backgroundColor))
            .overlay(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius, corners: corners
                )
                .stroke(
                    borderColor ?? Color(colors.innerBorder),
                    lineWidth: 1.0
                )
            )
            .clipShape(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius,
                    corners: corners
                )
            )
    }
    
    private var corners: UIRectCorner {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }
    
    private var backgroundColor: UIColor {
        if message.isSentByCurrentUser {
            return colors.background8
        } else {
            return colors.background6
        }
    }
}

extension View {
    public func reactionsBubble(for message: ChatMessage) -> some View {
        modifier(ReactionsBubbleModifier(message: message))
    }
}
