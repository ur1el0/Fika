//
//  DiscoverView.swift
//  Common Ground
//
//  Tinder / Bumble / FB Dating swipe deck with stacked cards, 5-button action dock, and match celebration
//

import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Live SwiftData Queries
    @Query(filter: #Predicate<DatingProfile> { $0.isCurrentUser })
    private var currentUserList: [DatingProfile]
    
    @Query(filter: #Predicate<DatingProfile> { !$0.isCurrentUser }, sort: \.createdAt, order: .forward)
    private var allFictionalProfiles: [DatingProfile]
    
    @Query
    private var connections: [Connection]
    
    @State private var viewModel = DiscoverViewModel()
    @State private var isShowingFilterDrawer: Bool = false
    @State private var matchedDatePlanConnection: Connection? = nil
    @State private var isPresentingDatePlanForm: Bool = false
    
    private var currentUser: DatingProfile? {
        currentUserList.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Canvas
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Dating App Navigation Header
                    datingTopHeader
                    
                    // Expandable Filter & Search Drawer
                    if isShowingFilterDrawer {
                        filterDrawer
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Live Feedback Toast (e.g. Undo, error)
                    if let message = viewModel.feedbackMessage {
                        feedbackToast(message: message, isError: false)
                    }
                    if let error = viewModel.errorMessage {
                        feedbackToast(message: error, isError: true)
                    }
                    
                    // Feed Content (Swipe Deck / Empty Radar)
                    let filtered = viewModel.filterProfiles(allFictionalProfiles)
                    
                    if filtered.isEmpty {
                        Spacer()
                        EmptyStateCard(
                            iconName: "magnifyingglass",
                            title: "No Profiles Found",
                            message: "Try clearing your search or switching your interest filter to see more profiles.",
                            actionTitle: "Reset Filters",
                            action: {
                                withAnimation {
                                    viewModel.searchText = ""
                                    viewModel.selectedInterestFilter = nil
                                    viewModel.resetIndex()
                                }
                            }
                        )
                        Spacer()
                    } else if viewModel.currentIndex >= filtered.count {
                        // Reached end of current deck -> Tinder Radar Sonar State
                        Spacer()
                        radarEmptyState(filteredCount: filtered.count)
                        Spacer()
                    } else {
                        let currentProfile = filtered[viewModel.currentIndex]
                        let isAlreadyConnected = connections.contains { $0.profile?.id == currentProfile.id }
                        
                        // Active Card Deck
                        VStack(spacing: Theme.Spacing.sm) {
                            deckProgressCounter(total: filtered.count)
                            
                            // Stack of Cards (Top card interactive, background cards stacked for depth)
                            ZStack {
                                // Background Card 2 (if available)
                                if viewModel.currentIndex + 2 < filtered.count {
                                    let p2 = filtered[viewModel.currentIndex + 2]
                                    ProfileCardView(
                                        profile: p2,
                                        currentUser: currentUser,
                                        isTopCard: false,
                                        onLike: {},
                                        onPass: {},
                                        onSuperLike: {},
                                        onSelect: {}
                                    )
                                    .scaleEffect(0.90)
                                    .offset(y: 22)
                                    .opacity(0.55)
                                    .allowsHitTesting(false)
                                }
                                
                                // Background Card 1 (if available)
                                if viewModel.currentIndex + 1 < filtered.count {
                                    let p1 = filtered[viewModel.currentIndex + 1]
                                    ProfileCardView(
                                        profile: p1,
                                        currentUser: currentUser,
                                        isTopCard: false,
                                        onLike: {},
                                        onPass: {},
                                        onSuperLike: {},
                                        onSelect: {}
                                    )
                                    .scaleEffect(0.95)
                                    .offset(y: 11)
                                    .opacity(0.88)
                                    .allowsHitTesting(false)
                                }
                                
                                // Top Interactive Card
                                ProfileCardView(
                                    profile: currentProfile,
                                    currentUser: currentUser,
                                    isTopCard: true,
                                    isConnected: isAlreadyConnected,
                                    onLike: {
                                        withAnimation {
                                            viewModel.connect(
                                                profile: currentProfile,
                                                currentUser: currentUser,
                                                existingConnections: connections,
                                                context: modelContext
                                            )
                                        }
                                    },
                                    onPass: {
                                        withAnimation {
                                            viewModel.pass(profile: currentProfile)
                                        }
                                    },
                                    onSuperLike: {
                                        withAnimation {
                                            viewModel.superLike(
                                                profile: currentProfile,
                                                currentUser: currentUser,
                                                existingConnections: connections,
                                                context: modelContext
                                            )
                                        }
                                    },
                                    onSelect: {
                                        viewModel.selectedProfileForDetail = currentProfile
                                    }
                                )
                                .id(currentProfile.id)
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 4)
                            .padding(.bottom, 6)
                            .frame(maxHeight: .infinity)
                            
                            // Iconic 5-Button Action Dock (Rewind, Nope, Super Like, Like, Info)
                            actionButtonDock(currentProfile: currentProfile, filtered: filtered)
                                .padding(.bottom, Theme.Spacing.sm)
                        }
                    }
                }
                
                // Match Celebration Overlay (Tinder / Bumble / FB Dating style)
                if let matched = viewModel.matchedProfile {
                    matchCelebrationOverlay(matched: matched)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .zIndex(100)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $viewModel.selectedProfileForDetail) { profile in
                ProfileDetailView(profile: profile, currentUser: currentUser)
            }
            .sheet(isPresented: $isPresentingDatePlanForm) {
                if let conn = matchedDatePlanConnection {
                    DatePlanFormView(connection: conn, planToEdit: nil)
                }
            }
            .onAppear {
                if CommandLine.arguments.contains("-detailProfile") {
                    viewModel.selectedProfileForDetail = allFictionalProfiles.first(where: { !$0.isCurrentUser })
                }
            }
        }
    }
    
    // MARK: - Navigation Header (Dating App Style)
    
    private var datingTopHeader: some View {
        HStack(alignment: .center) {
            // Left: User Avatar Thumbnail
            if let user = currentUser {
                AvatarPlaceholderView(
                    name: user.displayName,
                    size: 38
                )
            } else {
                Circle()
                    .fill(Theme.Colors.secondaryCardBackground)
                    .frame(width: 38, height: 38)
            }
            
            Spacer()
            
            // Center: App Branding Logo & Title
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.Gradients.datingFlame)
                
                Text("Fika")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.Gradients.datingFlame)
            }
            
            Spacer()
            
            // Right: Filter Toggle Button with Badge
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isShowingFilterDrawer.toggle()
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isShowingFilterDrawer ? "xmark.circle.fill" : "slider.horizontal.3")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isFilterActive ? Theme.Colors.accentCoral : Theme.Colors.primaryText)
                        .padding(8)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Theme.Colors.divider, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    
                    if isFilterActive && !isShowingFilterDrawer {
                        Circle()
                            .fill(Theme.Colors.accentCoral)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: 2)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.xs)
        .padding(.bottom, Theme.Spacing.xs)
    }
    
    private var isFilterActive: Bool {
        viewModel.selectedInterestFilter != nil || !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Filter & Search Drawer
    
    private var filterDrawer: some View {
        VStack(spacing: Theme.Spacing.xs) {
            // Search Input Field
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("Search by name, city, bio, interest...", text: $viewModel.searchText)
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.primaryText)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        viewModel.resetIndex()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, 8)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
            .padding(.horizontal, Theme.Spacing.md)
            
            // Horizontal Interest Filter Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.xs) {
                    InterestTagPill(
                        title: "All Interests",
                        isSelected: viewModel.selectedInterestFilter == nil,
                        action: {
                            withAnimation {
                                viewModel.selectedInterestFilter = nil
                                viewModel.resetIndex()
                            }
                        }
                    )
                    
                    ForEach(DataSeeder.availableInterests, id: \.self) { interest in
                        InterestTagPill(
                            title: interest,
                            isSelected: viewModel.selectedInterestFilter == interest,
                            action: {
                                withAnimation {
                                    viewModel.selectedInterestFilter = interest
                                    viewModel.resetIndex()
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.xs)
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.Colors.secondaryCardBackground.opacity(0.6))
    }
    
    // MARK: - Deck Counter
    
    private func deckProgressCounter(total: Int) -> some View {
        HStack {
            Text("Profile \(viewModel.currentIndex + 1) of \(total)")
                .font(.caption.weight(.semibold))
                .foregroundColor(Theme.Colors.secondaryText)
            
            Spacer()
            
            if viewModel.canUndo {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        viewModel.undoLastSwipe(context: modelContext)
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Undo")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundColor(Theme.Colors.swipeRewind)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
    
    // MARK: - The Iconic 5-Button Action Dock (Tinder / Bumble / FB Dating)
    
    private func actionButtonDock(currentProfile: DatingProfile, filtered: [DatingProfile]) -> some View {
        HStack(spacing: 16) {
            // 1. ↺ REWIND (Undo previous swipe)
            Button {
                triggerHaptic(style: .medium)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    viewModel.undoLastSwipe(context: modelContext)
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(viewModel.canUndo ? Theme.Colors.swipeRewind : Color.gray.opacity(0.4))
                    .frame(width: 46, height: 46)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
            }
            .disabled(!viewModel.canUndo)
            .accessibilityLabel("Undo last swipe")
            
            // 2. ✕ NOPE / PASS
            Button {
                triggerHaptic(style: .medium)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    viewModel.pass(profile: currentProfile)
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Theme.Colors.swipeNope)
                    .frame(width: 58, height: 58)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
            }
            .accessibilityLabel("Pass on \(currentProfile.displayName)")
            
            // 3. ★ SUPER LIKE
            Button {
                triggerHaptic(style: .heavy)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    viewModel.superLike(
                        profile: currentProfile,
                        currentUser: currentUser,
                        existingConnections: connections,
                        context: modelContext
                    )
                }
            } label: {
                Image(systemName: "star.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.Colors.swipeSuperLike)
                    .frame(width: 48, height: 48)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
            }
            .accessibilityLabel("Super like \(currentProfile.displayName)")
            
            // 4. ♥ LIKE / CONNECT
            Button {
                triggerHaptic(style: .medium)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    viewModel.connect(
                        profile: currentProfile,
                        currentUser: currentUser,
                        existingConnections: connections,
                        context: modelContext
                    )
                }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.Colors.swipeLike)
                    .frame(width: 58, height: 58)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
            }
            .accessibilityLabel("Like \(currentProfile.displayName)")
            
            // 5. ℹ PROFILE INFO
            Button {
                triggerHaptic(style: .light)
                viewModel.selectedProfileForDetail = currentProfile
            } label: {
                Image(systemName: "info")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.Colors.swipeBoost)
                    .frame(width: 46, height: 46)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
            }
            .accessibilityLabel("View profile details for \(currentProfile.displayName)")
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    
    // MARK: - Sonar Radar Pulse Empty State
    
    private func radarEmptyState(filteredCount: Int) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            ZStack {
                // Expanding Radar Rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Theme.Colors.accentCoral.opacity(0.28), lineWidth: 2)
                        .frame(width: CGFloat(130 + i * 65), height: CGFloat(130 + i * 65))
                }
                
                // Pulsing Center Avatar
                if let user = currentUser {
                    AvatarPlaceholderView(
                        name: user.displayName,
                        size: 92
                    )
                    .shadow(color: Theme.Colors.accentCoral.opacity(0.35), radius: 16, x: 0, y: 6)
                }
            }
            .frame(height: 240)
            
            VStack(spacing: Theme.Spacing.xs) {
                Text("You're All Caught Up!")
                    .font(.title2.weight(.bold))
                    .fontDesign(.rounded)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("You've reviewed all available profiles for your current filters.")
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
            
            HStack(spacing: Theme.Spacing.md) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.resetIndex()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Review Again")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, 14)
                    .background(Theme.Gradients.datingFlame)
                    .clipShape(Capsule())
                    .shadow(color: Theme.Colors.accentCoral.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                
                if viewModel.canUndo {
                    Button {
                        withAnimation {
                            viewModel.undoLastSwipe(context: modelContext)
                        }
                    } label: {
                        Text("Undo Last Swipe")
                            .font(.headline)
                            .foregroundColor(Theme.Colors.primaryText)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, 14)
                            .background(Theme.Colors.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.Colors.divider, lineWidth: 1))
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    
    // MARK: - "It's a Match!" Celebration Overlay
    
    private func matchCelebrationOverlay(matched: DatingProfile) -> some View {
        ZStack {
            // Dark Blur Background
            Color.black.opacity(0.88).ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.lg) {
                Spacer()
                
                // Animated Sparkle Headline
                VStack(spacing: Theme.Spacing.xs) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(Theme.Colors.ochre)
                        Text("IT'S A MATCH!")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.Gradients.datingFlame)
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(Theme.Colors.ochre)
                    }
                    
                    let shared = matched.sharedInterests(with: currentUser)
                    if let firstShared = shared.first {
                        Text("You and \(matched.displayName) both love \(firstShared)!")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.9))
                    } else {
                        Text("You and \(matched.displayName) liked each other.")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                // Overlapping Avatars Linked with a Glowing Heart
                HStack(spacing: -24) {
                    if let user = currentUser {
                        AvatarPlaceholderView(
                            name: user.displayName,
                            size: 110
                        )
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    
                    AvatarPlaceholderView(
                        name: matched.displayName,
                        size: 110
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .overlay(
                    Circle()
                        .fill(Theme.Gradients.datingFlame)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                        .shadow(color: Theme.Colors.accentCoral.opacity(0.8), radius: 12, x: 0, y: 4)
                )
                .padding(.vertical, Theme.Spacing.md)
                
                // Preferred Date Highlight
                VStack(spacing: 4) {
                    Text("SUGGESTED FIRST DATE")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundColor(Theme.Colors.ochre)
                    Text(matched.preferredFirstDateActivity)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
                .padding(Theme.Spacing.md)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, Theme.Spacing.lg)
                
                Spacer()
                
                // Action Buttons: Plan Date Now or Keep Swiping
                VStack(spacing: Theme.Spacing.sm) {
                    Button {
                        // Find or prepare connection for date planning
                        if let conn = connections.first(where: { $0.profile?.id == matched.id }) {
                            matchedDatePlanConnection = conn
                            viewModel.matchedProfile = nil
                            isPresentingDatePlanForm = true
                        } else {
                            viewModel.matchedProfile = nil
                        }
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Schedule a Date Plan")
                        }
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.Gradients.datingFlame)
                        .clipShape(Capsule())
                        .shadow(color: Theme.Colors.accentCoral.opacity(0.5), radius: 12, x: 0, y: 4)
                    }
                    
                    Button {
                        withAnimation {
                            viewModel.matchedProfile = nil
                        }
                    } label: {
                        Text("Keep Swiping")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
    }
    
    // MARK: - Feedback Banner
    
    private func feedbackToast(message: String, isError: Bool) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : Theme.Colors.sage)
            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundColor(isError ? .red : Theme.Colors.primaryText)
            Spacer()
            Button {
                viewModel.feedbackMessage = nil
                viewModel.errorMessage = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, 8)
        .background(isError ? Color.red.opacity(0.1) : Theme.Colors.sage.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.bottom, 4)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
