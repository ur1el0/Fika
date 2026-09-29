//
//  ProfileDetailView.swift
//  Common Ground
//
//  Full profile detail view showing common ground alignment and connection actions
//

import SwiftUI
import SwiftData

struct ProfileDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let profile: DatingProfile
    let currentUser: DatingProfile?
    
    @Query private var connections: [Connection]
    
    @State private var feedbackMessage: String? = nil
    @State private var errorMessage: String? = nil
    @State private var isPresentingDatePlanSheet: Bool = false
    
    private var existingConnection: Connection? {
        connections.first(where: { $0.profile?.id == profile.id })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Banner
                headerSection
                
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Feedback toast if any
                    if let message = feedbackMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.Colors.sage)
                            Text(message)
                                .font(.footnote.weight(.medium))
                                .foregroundColor(Theme.Colors.primaryText)
                        }
                        .padding(Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.sage.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
                    }
                    
                    // Common Ground Alignment
                    let reason = profile.commonGroundReason(with: currentUser)
                    let sharedInterests = profile.sharedInterests(with: currentUser)
                    CommonGroundReasonCard(reasonText: reason, sharedCount: sharedInterests.count)
                    
                    // Detailed Story & Bio
                    biographySection
                    
                    // Preferred Date Activity
                    firstDateSection
                    
                    // All Interests
                    interestsSection
                    
                    // Connection Action Section
                    if !profile.isCurrentUser {
                        actionSection
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle(profile.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPresentingDatePlanSheet) {
            if let connection = existingConnection {
                DatePlanFormView(connection: connection, planToEdit: nil)
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            AvatarPlaceholderView(name: profile.displayName, size: 68, showBadge: true)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(profile.displayName)
                        .font(.title.weight(.semibold))
                        .fontDesign(.serif)
                        .foregroundColor(Theme.Colors.primaryText)
                        .minimumScaleFactor(0.85)
                        .lineLimit(1)
                    
                    Text("\(profile.age)")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Spacer()
                    
                    if let conn = existingConnection {
                        ConnectionStatusBadge(status: conn.typedStatus)
                    }
                }
                
                HStack(spacing: Theme.Spacing.sm) {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(profile.city)
                    }
                    
                    Text("•")
                    
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "heart.text.square")
                        Text(profile.relationshipIntent)
                    }
                }
                .font(.footnote)
                .foregroundColor(Theme.Colors.secondaryText)
            }
        }
    }
    
    private var biographySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("THE STORY")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text(profile.bio)
                .font(.body)
                .foregroundColor(Theme.Colors.primaryText)
                .lineSpacing(4)
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
    
    private var firstDateSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("PREFERRED FIRST DATE")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundColor(Theme.Colors.accentCoral)
            
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.title3)
                    .foregroundColor(Theme.Colors.accentCoral)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("The Activity")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text(profile.preferredFirstDateActivity)
                        .font(.body.weight(.medium))
                        .foregroundColor(Theme.Colors.primaryText)
                        .lineSpacing(2)
                }
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.accentSoft.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        }
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("PASSIONS & PURSUITS")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundColor(Theme.Colors.secondaryText)
            
            let userSet = Set(currentUser?.interests.map { $0.lowercased() } ?? [])
            FlowLayout(spacing: Theme.Spacing.xs) {
                ForEach(profile.interests, id: \.self) { interest in
                    let isShared = userSet.contains(interest.lowercased())
                    InterestTagPill(title: interest, isShared: isShared)
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
    
    private var actionSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            if let conn = existingConnection {
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Saved in your Connections")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Button {
                        isPresentingDatePlanSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Schedule a Date Plan")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            } else {
                Button {
                    saveConnection()
                } label: {
                    HStack {
                        Image(systemName: "bookmark.fill")
                        Text("Connect with \(profile.displayName)")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(.top, Theme.Spacing.md)
    }
    
    private func saveConnection() {
        let conn = Connection(
            status: ConnectionStatus.saved.rawValue,
            createdAt: Date(),
            profile: profile
        )
        modelContext.insert(conn)
        do {
            try modelContext.save()
            feedbackMessage = "Saved \(profile.displayName) to your Connections!"
        } catch {
            errorMessage = "Failed to save connection: \(error.localizedDescription)"
        }
    }
}
