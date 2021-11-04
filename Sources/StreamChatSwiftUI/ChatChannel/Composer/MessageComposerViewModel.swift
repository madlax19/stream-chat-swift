//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

public class MessageComposerViewModel: ObservableObject {
    @Published private(set) var pickerState: AttachmentPickerState = .photos
    @Published private(set) var imageAssets: PHFetchResult<PHAsset>?
    @Published private(set) var addedImages = [AddedImage]()
    
    public func change(pickerState: AttachmentPickerState) {
        if pickerState != self.pickerState {
            self.pickerState = pickerState
        }
    }
    
    func imageTapped(_ addedImage: AddedImage) {
        var images = [AddedImage]()
        var imageRemoved = false
        for image in addedImages {
            if image.id != addedImage.id {
                images.append(image)
            } else {
                imageRemoved = true
            }
        }
        
        if !imageRemoved {
            images.append(addedImage)
        }
        
        addedImages = images
    }
    
    func isImageSelected(with id: String) -> Bool {
        for image in addedImages {
            if image.id == id {
                return true
            }
        }

        return false
    }
    
    func askForPhotosPermission() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized, .limited:
                print("Good to proceed")
                let fetchOptions = PHFetchOptions()
                DispatchQueue.main.async { [unowned self] in
                    self.imageAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            @unknown default:
                print("Not handled status")
            }
        }
    }
}

public enum AttachmentPickerState {
    case files
    case photos
    case camera
}

struct AddedImage: Identifiable {
    let image: UIImage
    let id: String
}
