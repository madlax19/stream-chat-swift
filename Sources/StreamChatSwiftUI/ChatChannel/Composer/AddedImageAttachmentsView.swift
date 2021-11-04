//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AddedImageAttachmentsView: View {
    var images: [AddedImage]
    var onImageTap: (AddedImage) -> Void
    
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
                            TopRightView {
                                Button(action: {
                                    withAnimation {
                                        onImageTap(attachment)
                                    }
                                }, label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 16, height: 16)
                                        
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color.black.opacity(0.8))
                                    }
                                    .padding(.all, 4)
                                })
                            }
                        )
                }
            }
        }
        .frame(height: 100)
    }
}
