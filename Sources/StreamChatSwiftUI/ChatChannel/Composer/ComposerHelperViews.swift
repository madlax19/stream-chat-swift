//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct VideoIndicatorView: View {
    var body: some View {
        BottomLeftView {
            Image(systemName: "video.fill")
                .renderingMode(.template)
                .font(.system(size: 17, weight: .bold))
                .applyDefaultIconOverlayStyle()
        }
    }
}

struct VideoDurationIndicatorView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var duration: String
    
    var body: some View {
        BottomRightView {
            Text(duration)
                .foregroundColor(Color(colors.staticColorText))
                .font(fonts.footnoteBold)
                .padding(.all, 4)
        }
    }
}
