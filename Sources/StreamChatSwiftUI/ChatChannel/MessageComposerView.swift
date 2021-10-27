//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct MessageComposerView: View {
    @Binding var text: String
    var sendMessageTapped: () -> Void
    
    public var body: some View {
        HStack {
            TextField("Send a message", text: $text)
            Spacer()
            Button {
                sendMessageTapped()
            } label: {
                Text("Send")
            }
        }
        .padding()
    }
}
