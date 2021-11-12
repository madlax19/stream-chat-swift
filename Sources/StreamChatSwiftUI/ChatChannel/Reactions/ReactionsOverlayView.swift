//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ReactionsOverlayView<Factory: ViewFactory>: View {
    var factory: Factory
    var currentSnapshot: UIImage
    var messageDisplayInfo: MessageDisplayInfo
    var onBackgroundTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(uiImage: currentSnapshot)
                .blur(radius: 8)
                .transition(.opacity)
                .onTapGesture {
                    withAnimation {
                        onBackgroundTap()
                    }
                }
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                MessageView(
                    factory: factory,
                    message: messageDisplayInfo.message,
                    contentWidth: messageDisplayInfo.contentWidth,
                    isFirst: messageDisplayInfo.isFirst
                )
                .offset(
                    x: messageDisplayInfo.frame.origin.x,
                    y: messageDisplayInfo.frame.origin.y
                )
                .frame(
                    width: messageDisplayInfo.frame.width,
                    height: messageDisplayInfo.frame.height
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
