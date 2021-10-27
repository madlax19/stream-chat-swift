//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import AVKit
import Nuke
import NukeUI
import StreamChat
import SwiftUI

struct MessageView<Factory: ViewFactory>: View {
    @Injected(\.utils) var utils
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    var factory: Factory
    let message: ChatMessage
    var width: CGFloat?
    var showsAllInfo: Bool
    var onLongPress: (ChatMessage) -> Void
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isSentByCurrentUser {
                MessageSpacer(spacerWidth: spacerWidth)
            } else {
                if showsAllInfo {
                    factory.makeMessageAvatarView(for: message.author)
                } else {
                    Color.clear
                        .frame(width: CGSize.messageAvatarSize.width)
                }
            }
            
            VStack(alignment: message.isSentByCurrentUser ? .trailing : .leading) {
                MessageAttachmentView(
                    message: message,
                    contentWidth: contentWidth,
                    isFirst: showsAllInfo
                )
                .onLongPressGesture {
                    onLongPress(message)
                }
                
                if showsAllInfo {
                    Text(dateFormatter.string(from: message.createdAt))
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            }
            
//            .overlay(
//                !message.reactionScores.isEmpty ?
//                    ReactionsContainer(message: message) : nil
//            )
            
            if !message.isSentByCurrentUser {
                MessageSpacer(spacerWidth: spacerWidth)
            }
        }
    }
    
    private var contentWidth: CGFloat {
        let padding: CGFloat = 16
        let minimumWidth: CGFloat = 240
        let available = max(minimumWidth, (width ?? 0) - spacerWidth) - padding
        let avatarSize: CGFloat = 40
        let totalWidth = message.isSentByCurrentUser ? available : available - avatarSize
        return totalWidth
    }
    
    private var spacerWidth: CGFloat {
        (width ?? 0) / 4
    }
}

struct MessageSpacer: View {
    var spacerWidth: CGFloat?
    
    var body: some View {
        Spacer()
            .frame(minWidth: spacerWidth)
            .layoutPriority(-1)
    }
}
