//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct MessageComposerView: View, KeyboardReadable {
    // Initial popup size, before the keyboard is shown.
    @State private var popupSize: CGFloat = 350
    
    @Binding var text: String
    var sendMessageTapped: () -> Void
    
    @State var overlayShown = false {
        didSet {
            if overlayShown == true {
                resignFirstResponder()
            }
        }
    }
    
    public var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        overlayShown.toggle()
                    }
                } label: {
                    Text("show")
                }

                TextField("Send a message", text: $text)
                Spacer()
                Button {
                    sendMessageTapped()
                } label: {
                    Text("Send")
                }
            }
            .padding()
            
            AttachmentPickerView(height: overlayShown ? popupSize : 0)
                .offset(y: overlayShown ? 0 : popupSize)
                .animation(.spring())
        }
        .onReceive(keyboardPublisher) { visible in
            if visible {
                overlayShown = false
            }
        }
        .onReceive(keyboardHeight) { height in
            if height > 0 {
                self.popupSize = height
            }
        }
    }
}

public struct AttachmentPickerView: View {
    var height: CGFloat
    
    public var body: some View {
        Color.blue.frame(height: height)
    }
}
