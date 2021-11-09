//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AddedImageAttachmentsView: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    var images: [AddedAsset]
    var onDiscardAttachment: (String) -> Void
    
    public var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(images) { attachment in
                    Image(uiImage: attachment.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            ZStack {
                                DiscardAttachmentButton(
                                    attachmentIdentifier: attachment.id,
                                    onDiscard: onDiscardAttachment
                                )
                                
                                if attachment.type == .video {
                                    VideoIndicatorView()
                                    
                                    if let duration = attachment.extraData["duration"] as? String {
                                        VideoDurationIndicatorView(duration: duration)
                                    }
                                }
                            }
                        )
                }
            }
        }
        .frame(height: 100)
    }
}
