//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct MessageComposerView: View, KeyboardReadable {
    @Injected(\.colors) var colors
    
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
    
    @StateObject var viewModel: MessageComposerViewModel = ViewModelsFactory.makeMessageComposerViewModel()
    
    public var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Button {
                    withAnimation {
                        overlayShown.toggle()
                    }
                } label: {
                    Text("show")
                }

                VStack {
                    if !viewModel.addedImages.isEmpty {
                        AddedImageAttachmentsView(
                            images: viewModel.addedImages,
                            onImageTap: viewModel.imageTapped(_:)
                        )
                        .transition(.scale)
                        .animation(.default)
                    }
                    TextField("Send a message", text: $text)
                }
                .padding(.vertical, 8)
                .padding(.leading, 8)
                .background(Color(colors.background1))
                .cornerRadius(20)
                
                Spacer()
                Button {
                    sendMessageTapped()
                } label: {
                    Text("Send")
                }
            }
            .padding()
            
            AttachmentPickerView(
                viewModel: viewModel,
                isDisplayed: overlayShown,
                height: overlayShown ? popupSize : 0
            )
            .offset(y: overlayShown ? 0 : popupSize)
            .animation(.default)
        }
        .onReceive(keyboardPublisher) { visible in
            if visible {
                withAnimation(.easeInOut(duration: 0.02)) {
                    overlayShown = false
                }
            }
        }
        .onReceive(keyboardHeight) { height in
            if height > 0 {
                self.popupSize = height - bottomSafeArea
            }
        }
    }
}
