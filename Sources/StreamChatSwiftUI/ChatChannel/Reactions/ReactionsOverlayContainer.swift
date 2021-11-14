//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsOverlayContainer: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    
    let message: ChatMessage
    let contentRect: CGRect
    var onReactionTap: (MessageReactionType) -> Void
    
    var body: some View {
        VStack {
            ReactionsHStack(message: message) {
                ReactionsView(
                    message: message,
                    useLargeIcons: true,
                    reactions: reactions,
                    onReactionTap: onReactionTap
                )
            }
            
            Spacer()
        }
        .offset(
            x: offsetX,
            y: -20
        )
    }
    
    private var reactions: [MessageReactionType] {
        images.availableReactions.keys
            .map { $0 }
            .sorted(by: { lhs, rhs in
                lhs.rawValue < rhs.rawValue
            })
    }
    
    private var reactionsSize: CGFloat {
        let entrySize = 28
        return CGFloat(reactions.count * entrySize)
    }
    
    private var offsetX: CGFloat {
        let padding: CGFloat = 16
        if message.isSentByCurrentUser {
            var originX = contentRect.origin.x - reactionsSize / 2
            let total = originX + reactionsSize
            if total > availableWidth {
                originX = availableWidth - reactionsSize
            }
            return -(contentRect.origin.x - originX)
        } else {
            var originX = contentRect.origin.x - reactionsSize / 2
            if originX < 0 {
                originX = padding
            }
            
            return contentRect.origin.x - originX
        }
    }
    
    private var availableWidth: CGFloat {
        UIScreen.main.bounds.width
    }
}
