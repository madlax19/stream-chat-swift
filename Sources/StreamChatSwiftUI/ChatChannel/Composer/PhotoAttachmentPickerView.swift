//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

public struct PhotoAttachmentPickerView: View {
    @Injected(\.colors) var colors
    
    @StateObject var assetLoader = PhotoAssetLoader()
    
    var assets: PHFetchResultCollection
    var onImageTap: (AddedImage) -> Void
    var imageSelected: (String) -> Bool
    
    let columns = [GridItem(.adaptive(minimum: 120), spacing: 2)]
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(assets) { asset in
                    PhotoAttachmentCell(
                        assetLoader: assetLoader,
                        asset: asset,
                        onImageTap: onImageTap,
                        imageSelected: imageSelected
                    )
                }
            }
            .padding(.horizontal, 2)
            .animation(nil)
        }
    }
}

extension PHAsset: Identifiable {
    public var id: String {
        localIdentifier
    }
}

struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int

    let fetchResult: PHFetchResult<PHAsset>

    var endIndex: Int { fetchResult.count }
    var startIndex: Int { 0 }

    subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
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
            if let image = assetLoader.loadedImages[asset.localIdentifier] {
                Color(colors.background1)
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
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
                    )
                    .clipped()
            } else {
                Color(colors.background1)
                    .aspectRatio(1, contentMode: .fill)
                
                Image(uiImage: images.imagePlaceholder)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 56)
                    .foregroundColor(Color(colors.background2))
            }
        }
        .aspectRatio(1, contentMode: .fill)
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
        options.deliveryMode = .opportunistic
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 250, height: 250),
            contentMode: .aspectFit,
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
