//
//  InterestTagPill.swift
//  Common Ground
//
//  Reusable tag pill for profile interests and category filtering
//

import SwiftUI

struct InterestTagPill: View {
    let title: String
    var isShared: Bool = false
    var isSelected: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        if let action {
            Button(action: action) {
                pillContent
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityText)
            .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : [.isButton])
        } else {
            pillContent
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityText)
        }
    }
    
    private var pillContent: some View {
        HStack(spacing: Theme.Spacing.xs) {
            if isShared {
                Image(systemName: "sparkle")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Theme.Colors.accentCoral)
            }
            Text(title)
                .font(.footnote.weight(isSelected || isShared ? .semibold : .medium))
                .foregroundColor(foregroundColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isShared {
            return Theme.Colors.accentCoral
        } else {
            return Theme.Colors.primaryText
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Theme.Colors.accentCoral
        } else if isShared {
            return Theme.Colors.accentSoft
        } else {
            return Theme.Colors.secondaryCardBackground
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Theme.Colors.accentCoral
        } else if isShared {
            return Theme.Colors.accentCoral.opacity(0.3)
        } else {
            return Theme.Colors.divider
        }
    }
    
    private var accessibilityText: String {
        if isShared {
            return "\(title), shared interest"
        }
        return title
    }
}
