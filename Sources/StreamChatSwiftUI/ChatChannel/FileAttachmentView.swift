//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct FileAttachmentsContainer: View {
    var message: ChatMessage
    var width: CGFloat
    var isFirst: Bool
    
    public var body: some View {
        VStack(spacing: 4) {
            ForEach(message.fileAttachments, id: \.self) { attachment in
                FileAttachmentView(
                    attachment: attachment,
                    width: width,
                    isFirst: isFirst
                )
            }
        }
        .padding(.all, 4)
        .messageBubble(for: message, isFirst: isFirst)
    }
}

public struct FileAttachmentView: View {
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    var attachment: ChatMessageFileAttachment
    var width: CGFloat
    var isFirst: Bool
    
    public var body: some View {
        HStack {
            Image(uiImage: previewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 40)
            VStack(alignment: .leading, spacing: 8) {
                Text(attachment.title ?? "")
                    .font(fonts.bodyBold)
                    .lineLimit(1)
                Text(attachment.file.sizeString)
                    .font(fonts.footnote)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            
            Spacer()
        }
        .padding(.all, 8)
        .background(Color(colors.background))
        .frame(width: width)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(colors.innerBorder), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private var previewImage: UIImage {
        let iconName = attachment.assetURL.pathExtension
        return images.documentPreviews[iconName] ?? images.fileFallback
    }
}
