//
//  AvatarPlaceholderView.swift
//  Common Ground
//
//  Editorial avatar and profile photo placeholder displaying person initials and photo indicator
//

import SwiftUI

struct AvatarPlaceholderView: View {
    let name: String
    var size: CGFloat = 64
    var showBadge: Bool = false
    
    private var initials: String {
        let parts = name.split(separator: " ").filter { !$0.isEmpty }
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let last = parts[parts.count - 1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return "CG"
    }
    
    private var tintColor: Color {
        let colors = [
            Theme.Colors.accentCoral,
            Theme.Colors.sage,
            Theme.Colors.ochre,
            Color(red: 0.55, green: 0.38, blue: 0.52), // muted plum
            Color(red: 0.38, green: 0.50, blue: 0.62)  // calm slate blue
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            tintColor.opacity(0.18),
                            tintColor.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(tintColor.opacity(0.35), lineWidth: max(1.5, size * 0.03))
                )
            
            // Person initials
            VStack(spacing: 0) {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .bold, design: .serif))
                    .foregroundColor(tintColor)
            }
            .frame(width: size, height: size)
            
            if showBadge {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.cardBackground)
                        .frame(width: size * 0.34, height: size * 0.34)
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: size * 0.20, weight: .medium))
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                .offset(x: 2, y: 2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Profile placeholder for \(name)")
    }
}
