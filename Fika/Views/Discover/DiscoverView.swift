//
//  DiscoverView.swift
//  Common Ground
//
//  Discover feed screen featuring intentional profile cards, interest filtering, Connect/Pass actions
//

import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Live SwiftData Queries
    @Query(filter: #Predicate<DatingProfile> { $0.isCurrentUser })
    private var currentUserList: [DatingProfile]
    
    @Query(filter: #Predicate<DatingProfile> { !$0.isCurrentUser }, sort: \.displayName)
    private var allFictionalProfiles: [DatingProfile]
    
    @Query
    private var connections: [Connection]
    
    @State private var viewModel = DiscoverViewModel()
    
    private var currentUser: DatingProfile? {
        currentUserList.first
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter and Search Header
                filterAndSearchBar
                
                // Live status/toast banner
                if let message = viewModel.feedbackMessage {
                    feedbackBanner(message: message, isError: false)
                }
                if let error = viewModel.errorMessage {
                    feedbackBanner(message: error, isError: true)
                }
                
                // Feed Content
                let filtered = viewModel.filterProfiles(allFictionalProfiles)
                
                if filtered.isEmpty {
                    Spacer()
                    EmptyStateCard(
                        iconName: "magnifyingglass",
                        title: "No Profiles Found",
                        message: "Try clearing your search or switching your interest filter to see more profiles.",
                        actionTitle: "Reset Filters",
                        action: {
                            viewModel.searchText = ""
                            viewModel.selectedInterestFilter = nil
                            viewModel.resetIndex()
                        }
                    )
                    Spacer()
                } else if viewModel.currentIndex >= filtered.count {
                    // Reached end of current deck
                    Spacer()
                    EmptyStateCard(
                        iconName: "sparkles",
                        title: "You're All Caught Up",
                        message: "You've reviewed all available profiles for this filter. Start over to review them again or switch categories.",
                        actionTitle: "Review Again",
                        action: {
                            withAnimation {
                                viewModel.resetIndex()
                            }
                        }
                    )
                    Spacer()
                } else {
                    let currentProfile = filtered[viewModel.currentIndex]
                    let isAlreadyConnected = connections.contains { $0.profile?.id == currentProfile.id }
                    
                    ScrollView {
                        VStack(spacing: Theme.Spacing.md) {
                            // Deck index counter
                            HStack {
                                Text("Profile \(viewModel.currentIndex + 1) of \(filtered.count)")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(Theme.Colors.secondaryText)
                                Spacer()
                                Button("Start Over") {
                                    withAnimation {
                                        viewModel.resetIndex()
                                    }
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.Colors.accentCoral)
                            }
                            .padding(.horizontal, Theme.Spacing.lg)
                            .padding(.top, Theme.Spacing.sm)
                            
                            ProfileCardView(
                                profile: currentProfile,
                                currentUser: currentUser,
                                isConnected: isAlreadyConnected,
                                onConnect: {
                                    withAnimation {
                                        viewModel.connect(
                                            profile: currentProfile,
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
                                onSelect: {
                                    viewModel.selectedProfileForDetail = currentProfile
                                }
                            )
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.bottom, Theme.Spacing.xl)
                        }
                    }
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $viewModel.selectedProfileForDetail) { profile in
                ProfileDetailView(profile: profile, currentUser: currentUser)
            }
            .onAppear {
                if CommandLine.arguments.contains("-detailProfile") {
                    viewModel.selectedProfileForDetail = allFictionalProfiles.first(where: { !$0.isCurrentUser })
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var filterAndSearchBar: some View {
        VStack(spacing: Theme.Spacing.xs) {
            // Search Bar
            HStack {
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
        .background(Theme.Colors.background)
    }
    
    private func feedbackBanner(message: String, isError: Bool) -> some View {
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
        .background(isError ? Color.red.opacity(0.1) : Theme.Colors.sage.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
        .padding(.horizontal, Theme.Spacing.md)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
