//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

public class MessageComposerViewModel: ObservableObject {
    @Published private(set) var pickerState: AttachmentPickerState = .photos
    @Published private(set) var imageAssets: PHFetchResult<PHAsset>?
    @Published private(set) var addedImages = [AddedImage]() {
        didSet {
            pickerTypeState = addedImages.count > 0 ? .collapsed : .expanded(.media)
        }
    }

    @Published var text = "" {
        didSet {
            if text != "" {
                // TODO: check for the three rows
                pickerTypeState = .collapsed
                channelController.sendKeystrokeEvent()
            }
        }
    }

    @Published var pickerTypeState: PickerTypeState = .expanded(.none) {
        didSet {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                overlayShown = attachmentPickerType != .none
            case .collapsed:
                log.debug("Collapsed state shown, no changes to overlay.")
            }
        }
    }

    @Published private(set) var overlayShown = false {
        didSet {
            if overlayShown == true {
                resignFirstResponder()
            }
        }
    }
    
    private let channelController: ChatChannelController
    
    public init(channelController: ChatChannelController) {
        self.channelController = channelController
    }
    
    // TODO: temp implementation.
    public func sendMessage() {
        channelController.createNewMessage(text: text) {
            switch $0 {
            case let .success(response):
                print(response)
            case let .failure(error):
                print(error)
            }
        }
        
        text = ""
    }
    
    public var sendButtonEnabled: Bool {
        !addedImages.isEmpty || !text.isEmpty
    }
    
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
