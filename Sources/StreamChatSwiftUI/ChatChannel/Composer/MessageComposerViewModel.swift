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
                withAnimation {
                    cameraPickerShown = true
                }
            } else if pickerState == .files {
                withAnimation {
                    filePickerShown = true
                }
            }
        }
    }

    @Published private(set) var imageAssets: PHFetchResult<PHAsset>?
    @Published private(set) var addedAssets = [AddedAsset]() {
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
    public func sendMessage(completion: @escaping () -> Void) {
        var attachments = addedAssets.map { added in
            try! AnyAttachmentPayload(
                localFileURL: added.url,
                attachmentType: added.type == .video ? .video : .image
            )
        }
        
        attachments += addedFileURLs.map { url in
            _ = url.startAccessingSecurityScopedResource()
            return try! AnyAttachmentPayload(localFileURL: url, attachmentType: .file)
        }
        
        channelController.createNewMessage(text: text, attachments: attachments) {
            switch $0 {
            case .success:
                completion()
            case let .failure(error):
                print(error)
            }
        }
        
        text = ""
        addedAssets = []
        addedFileURLs = []
        pickerTypeState = .expanded(.none)
    }
    
    public var sendButtonEnabled: Bool {
        !addedAssets.isEmpty || !text.isEmpty || !addedFileURLs.isEmpty
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
        
        if addedFileURLs.count == 2 && !addedAssets.isEmpty {
            return true
        }
        
        return false
    }
    
    func imageTapped(_ addedAsset: AddedAsset) {
        var images = [AddedAsset]()
        var imageRemoved = false
        for image in addedAssets {
            if image.id != addedAsset.id {
                images.append(image)
            } else {
                imageRemoved = true
            }
        }
        
        if !imageRemoved {
            images.append(addedAsset)
        }
        
        addedAssets = images
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
            var images = [AddedAsset]()
            for image in addedAssets {
                if image.id != id {
                    images.append(image)
                }
            }
            addedAssets = images
        }
    }
    
    func cameraImageAdded(_ image: AddedAsset) {
        addedAssets.append(image)
        pickerState = .photos
    }
    
    func isImageSelected(with id: String) -> Bool {
        for image in addedAssets {
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
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                DispatchQueue.main.async { [unowned self] in
                    self.imageAssets = PHAsset.fetchAssets(with: fetchOptions)
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
        pickerTypeState = (!addedAssets.isEmpty || !addedFileURLs.isEmpty) ? .collapsed : .expanded(.media)
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

struct AddedAsset: Identifiable {
    let image: UIImage
    let id: String
    let url: URL
    let type: AssetType
}

enum AssetType {
    case image
    case video
}
