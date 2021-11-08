//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AttachmentPickerView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    @StateObject var viewModel: MessageComposerViewModel
    
    var isDisplayed: Bool
    var height: CGFloat
    
    public var body: some View {
        VStack(spacing: 0) {
            AttachmentSourcePickerView(
                selected: viewModel.pickerState,
                onTap: viewModel.change(pickerState:)
            )
            
            if viewModel.pickerState == .photos {
                if let assets = viewModel.imageAssets,
                   let collection = PHFetchResultCollection(fetchResult: assets) {
                    AttachmentTypeContainer {
                        PhotoAttachmentPickerView(
                            assets: collection,
                            onImageTap: viewModel.imageTapped(_:),
                            imageSelected: viewModel.isImageSelected(with:)
                        )
                    }
                } else {
                    Text("permissions screen")
                    Spacer()
                }
                
            } else if viewModel.pickerState == .files {
                AttachmentTypeContainer {
                    ZStack {
                        Button {
                            viewModel.filePickerShown = true
                        } label: {
                            Text("Add more files")
                                .font(fonts.bodyBold)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(Color(colors.highlightedAccentBackground))
                    .sheet(isPresented: $viewModel.filePickerShown) {
                        FilePickerView(fileURLs: $viewModel.addedFileURLs)
                    }
                }
            } else {
                Spacer()
                    .sheet(isPresented: $viewModel.cameraPickerShown) {
                        ImagePickerView(sourceType: .camera) { addedImage in
                            viewModel.cameraImageAdded(addedImage)
                        }
                    }
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

struct AttachmentTypeContainer<Content: View>: View {
    @Injected(\.colors) var colors
    
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            Color(colors.background)
                .frame(height: 20)
            
            content()
                .background(Color(colors.background))
        }
        .background(Color(colors.background1))
        .cornerRadius(16)
    }
}

struct AttachmentSourcePickerView: View {
    @Injected(\.colors) var colors
    
    var selected: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            AttachmentPickerButton(
                iconName: "photo",
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                iconName: "folder",
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )
            
            AttachmentPickerButton(
                iconName: "camera",
                pickerType: .camera,
                isSelected: selected == .camera,
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
    var isSelected: Bool
    var onTap: (AttachmentPickerState) -> Void
    
    var body: some View {
        Button {
            onTap(pickerType)
        } label: {
            Image(systemName: iconName)
                .foregroundColor(
                    isSelected ? Color(colors.highlightedAccentBackground)
                        : Color(colors.textLowEmphasis)
                )
        }
    }
}
