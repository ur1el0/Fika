//
//  ProfileCardView.swift
//  Common Ground
//
//  Editorial card rendering a dating profile, emphasizing common ground, prompts, and actions
//

import SwiftUI

struct ProfileCardView: View {
    let profile: DatingProfile
    let currentUser: DatingProfile?
    var isConnected: Bool = false
    var onConnect: () -> Void
    var onPass: () -> Void
    var onSelect: () -> Void
    
    // Optional drag offset for swipe gesture
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Content (Tappable for Detail)
            Button(action: onSelect) {
                cardBody
            }
            .buttonStyle(.plain)
            
            Divider()
                .background(Theme.Colors.divider)
            
            // Action Buttons: Clear Connect and Pass buttons
            actionToolbar
        }
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .stroke(Theme.Colors.divider, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        .offset(x: dragOffset.width)
        .rotationEffect(.degrees(Double(dragOffset.width) / 25))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation
                }
                .onEnded { gesture in
                    if gesture.translation.width > 120 {
                        // Swiped right -> Connect
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = CGSize(width: 400, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            dragOffset = .zero
                            onConnect()
                        }
                    } else if gesture.translation.width < -120 {
                        // Swiped left -> Pass
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = CGSize(width: -400, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            dragOffset = .zero
                            onPass()
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }
    
    // MARK: - Subviews
    
    private var cardBody: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header row: Avatar, Name, Age, City & Demo Badge
            HStack(alignment: .center, spacing: Theme.Spacing.md) {
                AvatarPlaceholderView(name: profile.displayName, size: 54, showBadge: true)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Text(profile.displayName)
                            .font(.title2.weight(.semibold))
                            .fontDesign(.serif)
                            .foregroundColor(Theme.Colors.primaryText)
                        
                        Text("\(profile.age)")
                            .font(.title3)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                    
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                            .foregroundColor(Theme.Colors.secondaryText)
                        Text(profile.city)
                            .font(.footnote)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                Spacer()
                
                // Clear Fictional Demo Profile Indicator
                Text("DEMO PROFILE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.0)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .background(Theme.Colors.secondaryCardBackground)
                    .clipShape(Capsule())
            }
            
            // Common Ground Highlight
            let reason = profile.commonGroundReason(with: currentUser)
            let sharedCount = profile.sharedInterests(with: currentUser).count
            CommonGroundReasonCard(reasonText: reason, sharedCount: sharedCount)
            
            // Bio Prompt
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("ABOUT ME")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Text(profile.bio)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
                    .lineSpacing(3)
            }
            
            // Relationship Intention
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "heart.text.square")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.accentCoral)
                Text("Seeking: \(profile.relationshipIntent)")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Theme.Colors.secondaryCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
            
            // First Date Prompt
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("PREFERRED FIRST DATE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundColor(Theme.Colors.accentCoral)
                
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.accentCoral)
                        .padding(.top, 2)
                    Text(profile.preferredFirstDateActivity)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Theme.Colors.primaryText)
                        .lineSpacing(2)
                }
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.accentSoft.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            
            // Interests Tags (Highlighting Shared)
            let userShared = Set(currentUser?.interests.map { $0.lowercased() } ?? [])
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("INTERESTS")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                FlowLayout(spacing: Theme.Spacing.xs) {
                    ForEach(profile.interests, id: \.self) { interest in
                        let isShared = userShared.contains(interest.lowercased())
                        InterestTagPill(title: interest, isShared: isShared)
                    }
                }
            }
        }
        .padding(Theme.Spacing.lg)
    }
    
    private var actionToolbar: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Pass Button
            Button(action: onPass) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.bold))
                    Text("Pass")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(Theme.Colors.secondaryText)
                .background(Theme.Colors.secondaryCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            }
            .accessibilityLabel("Pass on \(profile.displayName)")
            
            // Connect Button
            Button(action: onConnect) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: isConnected ? "bookmark.fill" : "bookmark")
                        .font(.body.weight(.bold))
                    Text(isConnected ? "Connected" : "Connect")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(isConnected ? Theme.Colors.sage : Theme.Colors.accentCoral)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            }
            .accessibilityLabel(isConnected ? "Already connected with \(profile.displayName)" : "Connect with \(profile.displayName)")
        }
        .padding(Theme.Spacing.md)
    }
}

// MARK: - Simple Tag Flow Layout for SwiftUI
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeightInRow: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            x += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
        height = y + maxHeightInRow
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeightInRow: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
    }
}
