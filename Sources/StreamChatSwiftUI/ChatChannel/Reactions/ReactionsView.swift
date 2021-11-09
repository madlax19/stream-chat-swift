//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsContainer: View {
    let message: ChatMessage
    
    var body: some View {
        VStack {
            HStack {
                if !message.isSentByCurrentUser {
                    Spacer()
                }
                
                ReactionsView(message: message)
                
                if message.isSentByCurrentUser {
                    Spacer()
                }
            }
            
            Spacer()
        }
        .offset(
            x: offsetX,
            y: -20
        )
    }
    
    private var reactionsSize: CGFloat {
        let entrySize = 32
        return CGFloat(message.reactionScores.count * entrySize)
    }
    
    private var offsetX: CGFloat {
        var offset = reactionsSize / 3
        if message.reactionScores.count == 1 {
            offset = 16
        }
        return message.isSentByCurrentUser ? -offset : offset
    }
}

struct ReactionsView: View {
    let message: ChatMessage
    
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    var body: some View {
        HStack {
            ForEach(reactions) { reaction in
                if let image = iconProvider(for: reaction) {
                    Image(uiImage: image)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(color(for: reaction))
                        .frame(width: 20)
                }
            }
        }
        .padding(.all, 6)
        .reactionsBubble(for: message)
    }
    
    private func color(for reaction: MessageReactionType) -> Color {
        userReactionIDs
            .contains(reaction) ? Color(colors.highlightedAccentBackground) : Color(colors.textLowEmphasis)
    }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
    
    private var reactions: [MessageReactionType] {
        message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
    }
    
    private func iconProvider(for reaction: MessageReactionType) -> UIImage? {
        images.availableReactions[reaction]?.smallIcon
    }
}

extension MessageReactionType: Identifiable {
    public var id: String {
        rawValue
    }
}
