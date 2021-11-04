//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AttachmentPickerView: View {
    @Injected(\.colors) var colors
    
    @StateObject var viewModel: MessageComposerViewModel
    
    var isDisplayed: Bool
    var height: CGFloat
    
    public var body: some View {
        VStack(spacing: 0) {
            AttachmentSourcePickerView(onTap: viewModel.change(pickerState:))
            
            if viewModel.pickerState == .photos {
                if let assets = viewModel.imageAssets {
                    VStack(spacing: 0) {
                        Color(colors.background)
                            .frame(height: 20)
                        
                        PhotoAttachmentPickerView(
                            assets: assets,
                            onImageTap: viewModel.imageTapped(_:),
                            imageSelected: viewModel.isImageSelected(with:)
                        )
                        .background(Color(colors.background))
                    }
                    .background(Color(colors.background1))
                    .cornerRadius(16)

                } else {
                    Text("permissions screen")
                    Spacer()
                }
                
            } else {
                Spacer()
            }
        }
        .frame(height: height)
        .background(Color(colors.background1))
        .onChange(of: isDisplayed) { newValue in
            if newValue {
                viewModel.askForPhotosPermission()
            }
        }
    }
}

struct AttachmentSourcePickerView: View {
    @Injected(\.colors) var colors
    
    var onTap: (AttachmentPickerState) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            AttachmentPickerButton(
                iconName: "photo",
                pickerType: .photos,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                iconName: "folder",
                pickerType: .files,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                iconName: "camera",
                pickerType: .camera,
                onTap: onTap
            )
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(colors.background1))
    }
}

struct AttachmentPickerButton: View {
    @Injected(\.colors) var colors
    
    var iconName: String
    var pickerType: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void
    
    var body: some View {
        Button {
            onTap(pickerType)
        } label: {
            Image(systemName: iconName)
                .foregroundColor(Color(colors.textLowEmphasis))
        }
    }
}
