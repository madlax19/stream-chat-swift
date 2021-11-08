//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AddedFileAttachmentsView: View {
    @Injected(\.colors) var colors
    
    var addedFileURLs: [URL]
    var onDiscardAttachment: (String) -> Void
    
    public var body: some View {
        VStack {
            ForEach(0..<addedFileURLs.count, id: \.self) { i in
                let url = addedFileURLs[i]
                FileAttachmentDisplayView(
                    url: url,
                    title: url.lastPathComponent,
                    sizeString: ""
                )
                .padding(.all, 8)
                .background(Color(colors.background))
                .roundWithBorder()
                .id(url)
                .overlay(
                    DiscardAttachmentButton(
                        attachmentIdentifier: url.absoluteString,
                        onDiscard: onDiscardAttachment
                    )
                )
            }
        }
    }
}
