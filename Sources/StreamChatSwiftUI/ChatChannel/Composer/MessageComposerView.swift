//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageComposerView: View, KeyboardReadable {
    @Injected(\.colors) var colors
    
    // Initial popup size, before the keyboard is shown.
    @State private var popupSize: CGFloat = 350
    
    public init(
        channelController: ChatChannelController,
        onMessageSent: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeMessageComposerViewModel(with: channelController)
        )
        self.onMessageSent = onMessageSent
    }
    
    @StateObject var viewModel: MessageComposerViewModel
        
    var onMessageSent: () -> Void
    
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
                    onTap: {
                        viewModel.sendMessage {
                            onMessageSent()
                        }
                    }
                )
                .padding(.bottom, 8)
            }
            .padding(.all, 8)
            
            AttachmentPickerView(
                viewModel: viewModel,
                isDisplayed: viewModel.overlayShown,
                height: viewModel.overlayShown ? popupSize : 0
            )
            .offset(y: viewModel.overlayShown ? 0 : popupSize)
            .animation(.spring())
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
        .alert(isPresented: $viewModel.errorShown) {
            Alert.defaultErrorAlert
        }
    }
}

struct ComposerInputView: View {
    @Injected(\.colors) var colors
    
    @StateObject var viewModel: MessageComposerViewModel
    
    @State var textHeight: CGFloat = 34
    
    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = 34
        let maxHeight: CGFloat = 70
            
        if textHeight < minHeight {
            return minHeight
        }
            
        if textHeight > maxHeight {
            return maxHeight
        }
            
        return textHeight
    }
    
    var body: some View {
        VStack {
            if !viewModel.addedAssets.isEmpty {
                AddedImageAttachmentsView(
                    images: viewModel.addedAssets,
                    onDiscardAttachment: viewModel.removeAttachment(with:)
                )
                .transition(.scale)
                .animation(.default)
            }
            
            if !viewModel.addedFileURLs.isEmpty {
                if !viewModel.addedAssets.isEmpty {
                    Divider()
                }
                
                AddedFileAttachmentsView(
                    addedFileURLs: viewModel.addedFileURLs,
                    onDiscardAttachment: viewModel.removeAttachment(with:)
                )
                .padding(.trailing, 8)
            }
            
            ComposerTextInputView(
                text: $viewModel.text,
                height: $textHeight,
                placeholder: "Send a message"
            )
            .frame(height: textFieldHeight)
        }
        .padding(.vertical, shouldAddVerticalPadding ? 8 : 0)
        .padding(.leading, 8)
        .background(Color(colors.background))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(colors.innerBorder))
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
    
    private var shouldAddVerticalPadding: Bool {
        !viewModel.addedFileURLs.isEmpty ||
            !viewModel.addedAssets.isEmpty
    }
}
