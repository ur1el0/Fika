//
//  MyProfileView.swift
//  Common Ground
//
//  View and manage the current user's profile, view app metrics, and reset demo data
//

import SwiftUI
import SwiftData

struct MyProfileView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Live query for current user profile
    @Query(filter: #Predicate<DatingProfile> { $0.isCurrentUser })
    private var currentUserList: [DatingProfile]
    
    // Live query for stats
    @Query private var connections: [Connection]
    @Query private var datePlans: [DatePlan]
    
    @State private var viewModel = ProfileViewModel()
    @State private var verificationResult: CRUDVerifier.VerificationResult? = nil
    
    private var currentUser: DatingProfile? {
        currentUserList.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    if let user = currentUser {
                        // User Profile Summary Card
                        profileCard(user: user)
                        
                        // App Stats
                        statsRow
                        
                        // Bio & Outlook
                        bioSection(user: user)
                        
                        // First Date
                        firstDateSection(user: user)
                        
                        // Interests
                        interestsSection(user: user)
                        
                        // Academic Project & Data Controls
                        projectInfoSection
                    } else {
                        EmptyStateCard(
                            iconName: "person.crop.circle.badge.exclamationmark",
                            title: "No Profile Found",
                            message: "Please complete onboarding to set up your profile."
                        )
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("My Profile")
            .toolbar {
                if let user = currentUser {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            viewModel.isPresentingEditSheet = true
                        }
                        .foregroundColor(Theme.Colors.accentCoral)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresentingEditSheet) {
                if let user = currentUser {
                    EditProfileView(profile: user)
                }
            }
            .alert("Reset Demo Data?", isPresented: $viewModel.isShowingResetAlert) {
                Button("Reset All Demo Data", role: .destructive) {
                    viewModel.resetDemoData(context: modelContext)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will restore the 8 default fictional demo profiles and clear connections and date plans. Your personal profile will be preserved.")
            }
        }
    }
    
    // MARK: - Sections
    
    private func profileCard(user: DatingProfile) -> some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            AvatarPlaceholderView(name: user.displayName, size: 56, showBadge: true)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.xs) {
                    Text(user.displayName)
                        .font(.title2.weight(.semibold))
                        .fontDesign(.serif)
                        .foregroundColor(Theme.Colors.primaryText)
                        .minimumScaleFactor(0.85)
                        .lineLimit(1)
                    
                    Text("\(user.age)")
                        .font(.title3)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Spacer()
                    
                    Text("MY PROFILE")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(0.8)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .foregroundColor(Theme.Colors.accentCoral)
                        .background(Theme.Colors.accentSoft)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: Theme.Spacing.xs) {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(user.city)
                    }
                    
                    Text("•")
                    
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "heart.text.square")
                        Text(user.relationshipIntent)
                    }
                }
                .font(.footnote)
                .foregroundColor(Theme.Colors.secondaryText)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .stroke(Theme.Colors.divider, lineWidth: 1)
        )
    }
    
    private var statsRow: some View {
        HStack(spacing: Theme.Spacing.md) {
            statBox(
                count: connections.count,
                label: "Connections Saved",
                icon: "bookmark.fill",
                color: Theme.Colors.accentCoral
            )
            statBox(
                count: datePlans.count,
                label: "Dates Scheduled",
                icon: "calendar.badge.clock",
                color: Theme.Colors.ochre
            )
        }
    }
    
    private func statBox(count: Int, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)
                Spacer()
                Text("\(count)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(Theme.Colors.primaryText)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .stroke(Theme.Colors.divider, lineWidth: 1)
        )
    }
    
    private func bioSection(user: DatingProfile) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("ABOUT ME")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text(user.bio)
                .font(.body)
                .foregroundColor(Theme.Colors.primaryText)
                .lineSpacing(3)
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                        .stroke(Theme.Colors.divider, lineWidth: 1)
                )
        }
    }
    
    private func firstDateSection(user: DatingProfile) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("PREFERRED FIRST DATE")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.accentCoral)
            
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(Theme.Colors.accentCoral)
                    .font(.headline)
                Text(user.preferredFirstDateActivity)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.accentSoft.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        }
    }
    
    private func interestsSection(user: DatingProfile) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("MY INTERESTS")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            FlowLayout(spacing: Theme.Spacing.xs) {
                ForEach(user.interests, id: \.self) { interest in
                    InterestTagPill(title: interest, isSelected: false)
                }
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var projectInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("SCHOOL PROJECT DEMONSTRATION")
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundColor(Theme.Colors.secondaryText)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Common Ground is an offline dating prototype demonstrating SwiftData persistence, custom relationships, and CRUD operations. All profiles shown in Discover are fictional.")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .lineSpacing(2)
                
                Divider().background(Theme.Colors.divider)
                
                Button {
                    let result = CRUDVerifier.runVerification(context: modelContext)
                    verificationResult = result
                } label: {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Run SwiftData CRUD & Cascade Verification")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.Colors.accentCoral)
                }
                
                if let res = verificationResult {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: res.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(res.isSuccess ? Theme.Colors.sage : .red)
                        Text(res.isSuccess ? "All SwiftData CRUD & Cascade tests passed!" : "Verification error.")
                            .font(.caption.weight(.medium))
                            .foregroundColor(res.isSuccess ? Theme.Colors.sage : .red)
                    }
                    .padding(.top, Theme.Spacing.xxs)
                }
                
                Divider().background(Theme.Colors.divider)
                
                Button(role: .destructive) {
                    viewModel.isShowingResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Demo Data to Initial State")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.red)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        }
        .padding(.top, Theme.Spacing.md)
    }
}
