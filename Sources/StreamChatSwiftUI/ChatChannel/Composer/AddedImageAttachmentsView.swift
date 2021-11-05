//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AddedImageAttachmentsView: View {
    var images: [AddedImage]
    var onDiscardAttachment: (String) -> Void
    
    public var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(images) { attachment in
                    Image(uiImage: attachment.image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 100)
                        .cornerRadius(12)
                        .overlay(
                            DiscardAttachmentButton(
                                attachmentIdentifier: attachment.id,
                                onDiscard: onDiscardAttachment
                            )
                        )
                }
            }
        }
        .frame(height: 100)
    }
}
