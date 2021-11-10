//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

public struct AttachmentPickerView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
        
    var viewFactory: Factory
    var selectedPickerState: AttachmentPickerState
    @Binding var filePickerShown: Bool
    @Binding var cameraPickerShown: Bool
    @Binding var addedFileURLs: [URL]
    var onPickerStateChange: (AttachmentPickerState) -> Void
    var photoLibraryAssets: PHFetchResult<PHAsset>?
    var onAssetTap: (AddedAsset) -> Void
    var isAssetSelected: (String) -> Bool
    var cameraImageAdded: (AddedAsset) -> Void
    var askForAssetsAccessPermissions: () -> Void
    
    var isDisplayed: Bool
    var height: CGFloat
    
    public var body: some View {
        VStack(spacing: 0) {
            AttachmentSourcePickerView(
                selected: selectedPickerState,
                onTap: onPickerStateChange
            )
            
            if selectedPickerState == .photos {
                if let assets = photoLibraryAssets,
                   let collection = PHFetchResultCollection(fetchResult: assets) {
                    AttachmentTypeContainer {
                        PhotoAttachmentPickerView(
                            assets: collection,
                            onImageTap: onAssetTap,
                            imageSelected: isAssetSelected
                        )
                    }
                } else {
                    Text("permissions screen")
                    Spacer()
                }
                
            } else if selectedPickerState == .files {
                AttachmentTypeContainer {
                    ZStack {
                        Button {
                            filePickerShown = true
                        } label: {
                            Text("Add more files")
                                .font(fonts.bodyBold)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(Color(colors.highlightedAccentBackground))
                    .sheet(isPresented: $filePickerShown) {
                        FilePickerView(fileURLs: $addedFileURLs)
                    }
                }
            } else {
                Spacer()
                    .sheet(isPresented: $cameraPickerShown) {
                        ImagePickerView(sourceType: .camera) { addedImage in
                            cameraImageAdded(addedImage)
                        }
                    }
            }
        }
        .frame(height: height)
        .background(Color(colors.background1))
        .onChange(of: isDisplayed) { newValue in
            if newValue {
                askForAssetsAccessPermissions()
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
