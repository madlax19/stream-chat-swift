//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

public struct PhotoAttachmentPickerView: View {
    @Injected(\.colors) var colors
    
    @StateObject var assetLoader = PhotoAssetLoader()
    
    var assets: PHFetchResultCollection
    var onImageTap: (AddedAsset) -> Void
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

public struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    public typealias Element = PHAsset
    public typealias Index = Int

    public let fetchResult: PHFetchResult<PHAsset>

    public var endIndex: Int { fetchResult.count }
    public var startIndex: Int { 0 }

    public subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
    }
}

public struct PhotoAttachmentCell: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts
    
    @StateObject var assetLoader: PhotoAssetLoader
    
    @State var assetURL: URL?
    
    var asset: PHAsset
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    
    public var body: some View {
        ZStack {
            if let image = assetLoader.loadedImages[asset.localIdentifier] {
                GeometryReader { reader in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: reader.size.width, height: reader.size.height)
                        .clipped()
                        .onTapGesture {
                            withAnimation {
                                if let assetURL = assetURL {
                                    onImageTap(
                                        AddedAsset(
                                            image: image,
                                            id: asset.localIdentifier,
                                            url: assetURL,
                                            type: asset.mediaType == .video ? .video : .image,
                                            extraData: asset.mediaType == .video ? ["duration": asset.durationString] : [:]
                                        )
                                    )
                                }
                            }
                        }
                }
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
        .overlay(
            ZStack {
                if imageSelected(asset.localIdentifier) {
                    TopRightView {
                        Image(systemName: "checkmark.circle.fill")
                            .renderingMode(.template)
                            .applyDefaultIconOverlayStyle()
                    }
                }
                
                if asset.mediaType == .video {
                    VideoIndicatorView()
                    
                    VideoDurationIndicatorView(
                        duration: asset.durationString
                    )
                }
            }
        )
        .onAppear {
            assetLoader.loadImage(from: asset)
            asset.requestContentEditingInput(with: nil) { input, _ in
                if asset.mediaType == .image {
                    self.assetURL = input?.fullSizeImageURL
                } else if let url = (input?.audiovisualAsset as? AVURLAsset)?.url {
                    self.assetURL = url
                }
            }
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

extension PHAsset {
    var durationString: String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        var minutesString = "\(minutes)"
        var secondsString = "\(seconds)"
        if minutes < 10 {
            minutesString = "0" + minutesString
        }
        if seconds < 10 {
            secondsString = "0" + secondsString
        }
        
        return "\(minutesString):\(secondsString)"
    }
}
