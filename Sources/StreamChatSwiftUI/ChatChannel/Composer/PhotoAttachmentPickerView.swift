//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

public struct PhotoAttachmentPickerView: View {
    @Injected(\.colors) var colors
    
    @StateObject var assetLoader = PhotoAssetLoader()
    
    var assets: PHFetchResult<PHAsset>
    var onImageTap: (AddedImage) -> Void
    var imageSelected: (String) -> Bool
    
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 2)]
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<assets.count) { i in
                    PhotoAttachmentCell(
                        assetLoader: assetLoader,
                        asset: assets[i],
                        onImageTap: onImageTap,
                        imageSelected: imageSelected
                    )
                    .id(identifier(for: assets[i]))
                }
            }
            .padding(.horizontal, 2)
            .animation(nil)
        }
    }
    
    private func identifier(for asset: PHAsset) -> String {
        "\(asset.localIdentifier)-\(imageSelected(asset.localIdentifier))"
    }
}

public struct PhotoAttachmentCell: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    
    @StateObject var assetLoader: PhotoAssetLoader
    
    var asset: PHAsset
    var onImageTap: (AddedImage) -> Void
    var imageSelected: (String) -> Bool
    
    public var body: some View {
        ZStack {
            Color(colors.background1)
                .aspectRatio(1, contentMode: .fill)
            
            if let image = assetLoader.loadedImages[asset.localIdentifier] {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .onTapGesture {
                        withAnimation {
                            onImageTap(
                                AddedImage(
                                    image: image,
                                    id: asset.localIdentifier
                                )
                            )
                        }
                    }
                    .overlay(
                        imageSelected(asset.localIdentifier) ?
                            BottomRightView {
                                Image(systemName: "checkmark.circle.fill")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(colors.staticColorText))
                                    .padding(.all, 4)
                            }
                            : nil
                    )
            } else {
                Image(uiImage: images.imagePlaceholder)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 56)
                    .foregroundColor(Color(colors.background2))
            }
        }
        .onAppear {
            assetLoader.loadImage(from: asset)
        }
    }
}

public class PhotoAssetLoader: NSObject, ObservableObject {
    @Published var loadedImages = [String: UIImage]()
    
    func loadImage(from asset: PHAsset) {
        if loadedImages[asset.localIdentifier] != nil {
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            guard let self = self, let image = image else { return }
            self.loadedImages[asset.localIdentifier] = image
        }
    }
    
    func didReceiveMemoryWarning() {
        loadedImages = [String: UIImage]()
    }
}
