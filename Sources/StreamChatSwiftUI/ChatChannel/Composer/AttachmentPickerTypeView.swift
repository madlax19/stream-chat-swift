//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct AttachmentPickerTypeView: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    @Binding var pickerTypeState: PickerTypeState
    
    public var body: some View {
        HStack(spacing: 16) {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                PickerTypeButton(
                    pickerTypeState: $pickerTypeState,
                    pickerType: .media,
                    selected: attachmentPickerType
                )
                
                PickerTypeButton(
                    pickerTypeState: $pickerTypeState,
                    pickerType: .giphy,
                    selected: attachmentPickerType
                )
            case .collapsed:
                Button {
                    withAnimation {
                        pickerTypeState = .expanded(.none)
                    }
                } label: {
                    Image(uiImage: images.shrinkInputArrow)
                        .renderingMode(.template)
                        .foregroundColor(Color(colors.highlightedAccentBackground))
                }
            }
        }
    }
}

enum PickerTypeState {
    case expanded(AttachmentPickerType)
    case collapsed
}

enum AttachmentPickerType {
    case none
    case media
    case giphy
}

struct PickerTypeButton: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    @Binding var pickerTypeState: PickerTypeState
    
    let pickerType: AttachmentPickerType
    let selected: AttachmentPickerType
    
    var body: some View {
        Button {
            withAnimation {
                onTap(attachmentType: pickerType, selected: selected)
            }
        } label: {
            Image(uiImage: icon)
                .renderingMode(.template)
                .aspectRatio(contentMode: .fill)
                .frame(height: 18)
                .foregroundColor(
                    foregroundColor(for: pickerType, selected: selected)
                )
        }
    }
    
    private var icon: UIImage {
        if pickerType == .media {
            return images.openAttachments
        } else {
            return images.commands
        }
    }
    
    private func onTap(
        attachmentType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) {
        if selected == attachmentType {
            pickerTypeState = .expanded(.none)
        } else {
            pickerTypeState = .expanded(attachmentType)
        }
    }
    
    private func foregroundColor(
        for pickerType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) -> Color {
        if pickerType == selected {
            return Color(colors.highlightedAccentBackground)
        } else {
            return Color(colors.textLowEmphasis)
        }
    }
}
