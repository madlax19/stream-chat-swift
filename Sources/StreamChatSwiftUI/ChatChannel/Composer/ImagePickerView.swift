//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Image picker for loading images.
struct ImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    
    var onImagePicked: (AddedImage) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            pickerController.sourceType = sourceType
        }
        return pickerController
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    func makeCoordinator() -> ImagePickerCoordinator {
        Coordinator(self)
    }
}

final class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: ImagePickerView

    init(_ control: ImagePickerView) {
        parent = control
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let uiImage = info[.originalImage] as? UIImage, let imageURL = info[.imageURL] as? URL {
            let addedImage = AddedImage(
                image: uiImage,
                id: UUID().uuidString,
                url: imageURL
            )
            parent.onImagePicked(addedImage)
        }
        
        dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }

    private func dismiss() {
        parent.presentationMode.wrappedValue.dismiss()
    }
}
