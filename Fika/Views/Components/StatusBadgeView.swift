//
//  StatusBadgeView.swift
//  Common Ground
//
//  Accessible status badges for Connections and Date Plans
//

import SwiftUI

struct ConnectionStatusBadge: View {
    let status: ConnectionStatus
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: status.iconName)
                .font(.caption.weight(.semibold))
            Text(status.rawValue)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundColor(badgeColor)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(badgeColor.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Status: \(status.rawValue)")
    }
    
    private var badgeColor: Color {
        switch status {
        case .saved:
            return Theme.Colors.secondaryText
        case .mutualSpark:
            return Theme.Colors.accentCoral
        case .planningDate:
            return Theme.Colors.ochre
        case .connected:
            return Theme.Colors.sage
        case .archived:
            return Color.gray
        }
    }
}

struct DatePlanStatusBadge: View {
    let status: DatePlanStatus
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: status.iconName)
                .font(.caption.weight(.semibold))
            Text(status.rawValue)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundColor(badgeColor)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(badgeColor.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Date Plan Status: \(status.rawValue)")
    }
    
    private var badgeColor: Color {
        switch status {
        case .proposed:
            return Theme.Colors.ochre
        case .confirmed:
            return Theme.Colors.sage
        case .completed:
            return Theme.Colors.secondaryText
        case .canceled:
            return Color.red.opacity(0.8)
        }
    }
}
