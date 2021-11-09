//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct AttachmentUploadingStateView: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var uploadState: AttachmentUploadingState
    var url: URL
    
    var body: some View {
        Group {
            switch uploadState.state {
            case let .uploading(progress: progress):
                BottomRightView {
                    HStack(spacing: 4) {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .white)
                            )
                            .scaleEffect(0.7)
                        
                        Text(progressDisplay(for: progress))
                            .font(fonts.footnote)
                            .foregroundColor(Color(colors.staticColorText))
                    }
                    .padding(.all, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.all, 8)
                }
                
            case .uploadingFailed:
                Image(uiImage: images.messageListErrorIndicator)
                    .foregroundColor(Color(colors.alert))
            case .uploaded:
                TopRightView {
                    Image(uiImage: images.confirmCheckmark)
                        .renderingMode(.template)
                        .foregroundColor(Color.black.opacity(0.7))
                        .padding(.all, 8)
                }
                
            default:
                EmptyView()
            }
        }
        .id("\(url.absoluteString)-\(uploadState.state))")
    }
    
    private func progressDisplay(for progress: CGFloat) -> String {
        let value = Int(progress * 100)
        return "\(value)%"
    }
}

struct AttachmentUploadingStateViewModifier: ViewModifier {
    var uploadState: AttachmentUploadingState?
    var url: URL
    
    func body(content: Content) -> some View {
        content
            .overlay(
                uploadState != nil ? AttachmentUploadingStateView(uploadState: uploadState!, url: url) : nil
            )
    }
}

extension View {
    func withUploadingStateIndicator(for uploadState: AttachmentUploadingState?, url: URL) -> some View {
        modifier(AttachmentUploadingStateViewModifier(uploadState: uploadState, url: url))
    }
}
