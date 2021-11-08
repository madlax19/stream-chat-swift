//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

public class MessageComposerViewModel: ObservableObject {
    @Published private(set) var pickerState: AttachmentPickerState = .photos {
        didSet {
            if pickerState == .camera {
                cameraPickerShown = true
            }
        }
    }

    @Published private(set) var imageAssets: PHFetchResult<PHAsset>?
    @Published private(set) var addedImages = [AddedImage]() {
        didSet {
            checkPickerSelectionState()
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
    
    @Published var addedFileURLs = [URL]() {
        didSet {
            checkPickerSelectionState()
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
    
    @Published var filePickerShown = false
    @Published var cameraPickerShown = false
    
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
    
    public var inputComposerShouldScroll: Bool {
        if addedFileURLs.count > 2 {
            return true
        }
        
        if addedFileURLs.count == 2 && !addedImages.isEmpty {
            return true
        }
        
        return false
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
    
    func removeAttachment(with id: String) {
        if isURL(string: id), let url = URL(string: id) {
            var urls = [URL]()
            for added in addedFileURLs {
                if url != added {
                    urls.append(added)
                }
            }
            addedFileURLs = urls
        } else {
            var images = [AddedImage]()
            for image in addedImages {
                if image.id != id {
                    images.append(image)
                }
            }
            addedImages = images
        }
    }
    
    func cameraImageAdded(_ image: AddedImage) {
        addedImages.append(image)
        pickerState = .photos
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
    
    // MARK: - private
    
    private func checkPickerSelectionState() {
        pickerTypeState = (!addedImages.isEmpty || !addedFileURLs.isEmpty) ? .collapsed : .expanded(.media)
    }
    
    private func isURL(string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        
        guard (detector != nil && !string.isEmpty) else {
            return false
        }
        
        if detector!.numberOfMatches(
            in: string,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, string.count)
        ) > 0 {
            return true
        }
        
        return false
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
