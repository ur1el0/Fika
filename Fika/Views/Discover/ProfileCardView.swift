//
//  ProfileCardView.swift
//  Common Ground
//
//  Tinder / Bumble / FB Dating card with photo story pagination, gesture physics, and stamp overlays
//

import SwiftUI

struct ProfileCardView: View {
    let profile: DatingProfile
    let currentUser: DatingProfile?
    var isTopCard: Bool = true
    var isConnected: Bool = false
    
    var onLike: () -> Void
    var onPass: () -> Void
    var onSuperLike: () -> Void
    var onSelect: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var activeSlide: Int = 0
    @State private var isAnimatingOut: Bool = false
    
    private let totalSlides = 3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background Photo / Story Content
                slideContent(size: geometry.size)
                
                // Story Pagination Dash Indicators (Instagram / Tinder / Bumble style)
                VStack(spacing: 0) {
                    HStack(spacing: 5) {
                        ForEach(0..<totalSlides, id: \.self) { idx in
                            Capsule()
                                .fill(activeSlide == idx ? Color.white : Color.white.opacity(0.38))
                                .frame(height: 4)
                                .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, 14)
                    
                    Spacer()
                }
                
                // Gradient Scrim for Text Readability
                Theme.Gradients.cardOverlay
                    .allowsHitTesting(false)
                
                // Overlay Content (Bottom Information Card)
                bottomOverlay(size: geometry.size)
                
                // Invisible Tap Navigation Overlay for Left / Right Photo Story Tapping
                HStack(spacing: 0) {
                    // Left tap zone: previous slide
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                activeSlide = max(0, activeSlide - 1)
                            }
                        }
                        .frame(width: geometry.size.width * 0.35)
                    
                    // Center tap zone: open detail
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect()
                        }
                    
                    // Right tap zone: next slide
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                activeSlide = min(totalSlides - 1, activeSlide + 1)
                            }
                        }
                        .frame(width: geometry.size.width * 0.35)
                }
                .frame(maxHeight: geometry.size.height * 0.65)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Dynamic Stamp Overlays
                if isTopCard {
                    stampOverlays
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 16, x: 0, y: 8)
            .offset(x: dragOffset.width, y: dragOffset.height)
            .rotationEffect(.degrees(Double(dragOffset.width) / 18.0))
            .gesture(
                isTopCard ? dragGesture : nil
            )
        }
    }
    
    // MARK: - Slide Content
    
    @ViewBuilder
    private func slideContent(size: CGSize) -> some View {
        switch activeSlide {
        case 0:
            // Hero Placeholder Scene
            proceduralHeroScene(size: size)
            
        case 1:
            // Lifestyle & Bio Slide
            ZStack {
                Theme.Colors.cardBackground
                
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    HStack {
                        Image(systemName: "quote.bubble.fill")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.accentCoral)
                        Text("ABOUT ME")
                            .font(.caption.weight(.heavy))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Text("\"\(profile.bio)\"")
                        .font(.title3.weight(.medium))
                        .fontDesign(.serif)
                        .foregroundColor(.white)
                        .lineSpacing(5)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                    
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundColor(Theme.Colors.accentCoral)
                        Text("Looking for: \(profile.relationshipIntent)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, 50)
                .padding(.bottom, 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            
        default:
            // First Date & Passions Slide
            ZStack {
                Theme.Colors.cardBackground
                
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.ochre)
                        Text("FIRST DATE IDEA")
                            .font(.caption.weight(.heavy))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Text(profile.preferredFirstDateActivity)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .padding(Theme.Spacing.md)
                        .background(Color.white.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    Text("PASSIONS & INTERESTS")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.75))
                        .padding(.top, 8)
                    
                    let userShared = Set(currentUser?.interests.map { $0.lowercased() } ?? [])
                    FlowLayout(spacing: Theme.Spacing.xs) {
                        ForEach(profile.interests, id: \.self) { interest in
                            let isShared = userShared.contains(interest.lowercased())
                            HStack(spacing: 4) {
                                if isShared {
                                    Image(systemName: "sparkles")
                                        .font(.caption2)
                                }
                                Text(interest)
                                    .font(.caption.weight(.semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isShared ? Theme.Colors.accentCoral : Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, 50)
                .padding(.bottom, 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
    
    // MARK: - Procedural Hero Scene (Fallback if asset image missing)
    
    private func proceduralHeroScene(size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.16, blue: 0.28),
                    Color(red: 0.10, green: 0.08, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: Theme.Spacing.md) {
                AvatarPlaceholderView(name: profile.displayName, size: 120, showBadge: false)
                
                Text(profile.displayName)
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    // MARK: - Bottom Overlay Content
    
    private func bottomOverlay(size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Name, Age, Verified badge & Info button
            HStack(alignment: .center, spacing: Theme.Spacing.xs) {
                Text(profile.displayName)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                
                Text("\(profile.age)")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                
                // Verified Badge (Tinder / Bumble / FB Dating style)
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundColor(Color(red: 0.15, green: 0.65, blue: 1.0))
                
                Spacer()
                
                // Circular Info Button (Opens Profile Detail)
                Button(action: onSelect) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.92))
                        .background(Circle().fill(Color.black.opacity(0.35)))
                }
                .accessibilityLabel("View full profile for \(profile.displayName)")
            }
            
            // Location and Active Status
            HStack(spacing: Theme.Spacing.sm) {
                HStack(spacing: 3) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                    Text(profile.city)
                        .font(.footnote.weight(.medium))
                }
                
                Text("•")
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("Active recently")
                        .font(.footnote.weight(.medium))
                }
            }
            .foregroundColor(.white.opacity(0.85))
            
            // Common Ground Pill (FB Dating & Bumble Highlight)
            let reason = profile.commonGroundReason(with: currentUser)
            let sharedInterests = profile.sharedInterests(with: currentUser)
            if !sharedInterests.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.Colors.ochre)
                    
                    Text("Common Ground: \(sharedInterests.prefix(2).joined(separator: " & "))")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                .padding(.top, 2)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(Theme.Colors.accentCoral)
                    Text("Seeking: \(profile.relationshipIntent)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())
                .padding(.top, 2)
            }
            
            // Brief Bio Snippet (Slide 0)
            if activeSlide == 0 {
                Text(profile.bio)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
                    .lineSpacing(2)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Tinder / Bumble Stamp Overlays
    
    private var stampOverlays: some View {
        ZStack {
            // LIKE Stamp (Top-Left, shows when dragged right)
            VStack {
                HStack {
                    Text("LIKE")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .tracking(2.0)
                        .foregroundColor(Theme.Colors.swipeLike)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Theme.Colors.swipeLike, lineWidth: 4)
                        )
                        .rotationEffect(.degrees(-16))
                        .opacity(likeOpacity)
                        .scaleEffect(0.9 + 0.1 * likeOpacity)
                    
                    Spacer()
                }
                .padding(.top, 42)
                .padding(.leading, 24)
                
                Spacer()
            }
            
            // NOPE Stamp (Top-Right, shows when dragged left)
            VStack {
                HStack {
                    Spacer()
                    
                    Text("NOPE")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .tracking(2.0)
                        .foregroundColor(Theme.Colors.swipeNope)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Theme.Colors.swipeNope, lineWidth: 4)
                        )
                        .rotationEffect(.degrees(16))
                        .opacity(nopeOpacity)
                        .scaleEffect(0.9 + 0.1 * nopeOpacity)
                }
                .padding(.top, 42)
                .padding(.trailing, 24)
                
                Spacer()
            }
            
            // SUPER LIKE Stamp (Bottom/Center, shows when dragged upward)
            if superLikeOpacity > 0.05 {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.title2)
                        Text("SUPER LIKE")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .tracking(2.0)
                    }
                    .foregroundColor(Theme.Colors.swipeSuperLike)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.Colors.swipeSuperLike, lineWidth: 4)
                    )
                    .opacity(superLikeOpacity)
                    .scaleEffect(0.9 + 0.1 * superLikeOpacity)
                    .padding(.bottom, 120)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    // Dynamic Stamp Opacities based on Drag Translation
    private var likeOpacity: Double {
        Double(min(1.0, max(0.0, dragOffset.width / 75.0)))
    }
    
    private var nopeOpacity: Double {
        Double(min(1.0, max(0.0, -dragOffset.width / 75.0)))
    }
    
    private var superLikeOpacity: Double {
        if abs(dragOffset.width) < 90 && dragOffset.height < -20 {
            return Double(min(1.0, max(0.0, -dragOffset.height / 75.0)))
        }
        return 0.0
    }
    
    // MARK: - Drag Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                guard !isAnimatingOut else { return }
                dragOffset = gesture.translation
            }
            .onEnded { gesture in
                guard !isAnimatingOut else { return }
                
                if gesture.translation.width > 110 {
                    // Swiped Right -> LIKE
                    isAnimatingOut = true
                    triggerHaptic()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        dragOffset = CGSize(width: 550, height: gesture.translation.height * 1.3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        onLike()
                    }
                } else if gesture.translation.width < -110 {
                    // Swiped Left -> NOPE / PASS
                    isAnimatingOut = true
                    triggerHaptic()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        dragOffset = CGSize(width: -550, height: gesture.translation.height * 1.3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        onPass()
                    }
                } else if gesture.translation.height < -120 && abs(gesture.translation.width) < 100 {
                    // Swiped Up -> SUPER LIKE
                    isAnimatingOut = true
                    triggerHaptic()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        dragOffset = CGSize(width: 0, height: -750)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        onSuperLike()
                    }
                } else {
                    // Snap back to center
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                        dragOffset = .zero
                    }
                }
            }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Tag Flow Layout for SwiftUI
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

