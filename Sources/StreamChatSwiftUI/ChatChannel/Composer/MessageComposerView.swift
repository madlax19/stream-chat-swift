//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageComposerView: View, KeyboardReadable {
    @Injected(\.colors) var colors
    
    // Initial popup size, before the keyboard is shown.
    @State private var popupSize: CGFloat = 350
    
    public init(channelController: ChatChannelController) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeMessageComposerViewModel(with: channelController)
        )
    }
    
    @StateObject var viewModel: MessageComposerViewModel
    
    public var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                AttachmentPickerTypeView(pickerTypeState: $viewModel.pickerTypeState)
                    .padding(.bottom, 8)

                if viewModel.inputComposerShouldScroll {
                    ScrollView {
                        ComposerInputView(viewModel: viewModel)
                    }
                    .frame(height: 240)
                } else {
                    ComposerInputView(viewModel: viewModel)
                }
                
                Spacer()
                
                SendMessageButton(
                    enabled: viewModel.sendButtonEnabled,
                    onTap: viewModel.sendMessage
                )
                .padding(.bottom, 8)
            }
            .padding()
            
            AttachmentPickerView(
                viewModel: viewModel,
                isDisplayed: viewModel.overlayShown,
                height: viewModel.overlayShown ? popupSize : 0
            )
            .offset(y: viewModel.overlayShown ? 0 : popupSize)
            .animation(.default)
        }
        .onReceive(keyboardPublisher) { visible in
            if visible {
                withAnimation(.easeInOut(duration: 0.02)) {
                    viewModel.pickerTypeState = .expanded(.none)
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

struct ComposerInputView: View {
    @Injected(\.colors) var colors
    
    @StateObject var viewModel: MessageComposerViewModel
    
    var body: some View {
        VStack {
            if !viewModel.addedImages.isEmpty {
                AddedImageAttachmentsView(
                    images: viewModel.addedImages,
                    onDiscardAttachment: viewModel.removeAttachment(with:)
                )
                .transition(.scale)
                .animation(.default)
            }
            
            if !viewModel.addedFileURLs.isEmpty {
                if !viewModel.addedImages.isEmpty {
                    Divider()
                }
                
                AddedFileAttachmentsView(
                    addedFileURLs: viewModel.addedFileURLs,
                    onDiscardAttachment: viewModel.removeAttachment(with:)
                )
                .padding(.trailing, 8)
            }
            
            TextField("Send a message", text: $viewModel.text)
        }
        .padding(.vertical, 8)
        .padding(.leading, 8)
        .background(Color(colors.background1))
        .cornerRadius(20)
    }
}
