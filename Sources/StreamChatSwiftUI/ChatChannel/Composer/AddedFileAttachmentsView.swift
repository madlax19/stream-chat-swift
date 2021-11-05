//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AddedFileAttachmentsView: View {
    @Injected(\.colors) var colors
    
    var addedFileURLs: [URL]
    var onDiscardAttachment: (String) -> Void
    
    /*
     TODO:
     count (2) != its initial count (1). `ForEach(_:content:)` should only be used for *constant* data. Instead conform data to `Identifiable` or use `ForEach(_:id:content:)` and provide an explicit `id`!
     */
    public var body: some View {
        VStack {
            ForEach(0..<addedFileURLs.count) { i in
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
