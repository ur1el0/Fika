//
//  EmptyStateCard.swift
//  Common Ground
//
//  Editorial empty state presentation
//

import SwiftUI

struct EmptyStateCard: View {
    let iconName: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.secondaryCardBackground)
                    .frame(width: 64, height: 64)
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(Theme.Colors.accentCoral)
            }
            .accessibilityHidden(true)
            
            Text(title)
                .font(.headline)
                .fontDesign(.serif)
                .foregroundColor(Theme.Colors.primaryText)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.lg)
            
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.accentCoral)
                        .clipShape(Capsule())
                }
                .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .stroke(Theme.Colors.divider, lineWidth: 1)
        )
        .padding(.horizontal, Theme.Spacing.md)
    }
}
