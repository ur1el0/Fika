//
//  CommonGroundReasonCard.swift
//  Common Ground
//
//  Editorial banner displaying why two profiles share common ground
//

import SwiftUI

struct CommonGroundReasonCard: View {
    let reasonText: String
    var sharedCount: Int = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.accentSoft)
                    .frame(width: 36, height: 36)
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.accentCoral)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text("WHY COMMON GROUND")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundColor(Theme.Colors.accentCoral)
                    
                    if sharedCount > 0 {
                        Text("• \(sharedCount) Shared")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                Text(reasonText)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Theme.Colors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .stroke(Theme.Colors.accentCoral.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Common ground reason: \(reasonText)")
    }
}
