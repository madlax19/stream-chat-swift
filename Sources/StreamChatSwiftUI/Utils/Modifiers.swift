//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Modifier for adding shadow and corner radius to a view.
struct ShadowViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content.background(Color(UIColor.systemBackground))
            .cornerRadius(cornerRadius)
            .modifier(ShadowModifier())
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color(colors.background1),
                        lineWidth: 0.5
                    )
            )
    }
}

/// Modifier for adding shadow to a view.
struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
