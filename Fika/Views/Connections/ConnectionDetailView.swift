//
//  ConnectionDetailView.swift
//  Common Ground
//
//  Detailed view of a connection: manage status, view and create date plans, or cascade-delete
//

import SwiftUI
import SwiftData

struct ConnectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var connection: Connection
    
    @Query(filter: #Predicate<DatingProfile> { $0.isCurrentUser })
    private var currentUserList: [DatingProfile]
    
    @State private var isShowingDatePlanSheet: Bool = false
    @State private var isShowingDeleteAlert: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    private var currentUser: DatingProfile? {
        currentUserList.first
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Status Management Card
                statusManagementCard
                
                if let error = errorMessage {
                    banner(message: error, isError: true)
                }
                if let success = successMessage {
                    banner(message: success, isError: false)
                }
                
                // Profile Snapshot
                if let profile = connection.profile {
                    profileSnapshot(profile: profile)
                }
                
                // Date Plans Section
                datePlansSection
                
                // Destructive Delete Section
                deleteSection
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.lg)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle(connection.profile?.displayName ?? "Connection")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingDatePlanSheet) {
            DatePlanFormView(connection: connection, planToEdit: nil)
        }
        .alert("Delete Connection?", isPresented: $isShowingDeleteAlert) {
            Button("Delete Connection & Plans", role: .destructive) {
                deleteConnection()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Deleting this connection will also delete all associated date plans. This action cannot be undone.")
        }
    }
    
    // MARK: - Sections
    
    private var statusManagementCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("CONNECTION STATUS")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Spacer()
                
                ConnectionStatusBadge(status: connection.typedStatus)
            }
            
            Picker("Status", selection: Binding(
                get: { connection.typedStatus },
                set: { newStatus in
                    updateStatus(newStatus)
                }
            )) {
                ForEach(ConnectionStatus.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .stroke(Theme.Colors.divider, lineWidth: 1)
        )
    }
    
    private func profileSnapshot(profile: DatingProfile) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(profile.displayName)
                        .font(.title2.weight(.semibold))
                        .fontDesign(.serif)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Text("\(profile.age) • \(profile.city)")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
                
                NavigationLink {
                    ProfileDetailView(profile: profile, currentUser: currentUser)
                } label: {
                    Text("Full Profile")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Theme.Colors.accentCoral)
                }
            }
            
            let reason = profile.commonGroundReason(with: currentUser)
            CommonGroundReasonCard(reasonText: reason, sharedCount: profile.sharedInterests(with: currentUser).count)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("FIRST DATE PREFERENCE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Text(profile.preferredFirstDateActivity)
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.primaryText)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .stroke(Theme.Colors.divider, lineWidth: 1)
        )
    }
    
    private var datePlansSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("DATE PLANS")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Spacer()
                
                Button {
                    isShowingDatePlanSheet = true
                } label: {
                    Label("Add Plan", systemImage: "plus.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Theme.Colors.accentCoral)
                }
            }
            
            let plans = connection.datePlans ?? []
            if plans.isEmpty {
                VStack(spacing: Theme.Spacing.xs) {
                    Text("No date plans yet.")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                    Button("Plan a First Date") {
                        isShowingDatePlanSheet = true
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Theme.Colors.accentCoral)
                }
                .padding(Theme.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(Theme.Colors.secondaryCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            } else {
                ForEach(plans.sorted(by: { $0.scheduledAt < $1.scheduledAt })) { plan in
                    NavigationLink {
                        DatePlanDetailView(plan: plan)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                                Text(plan.activity)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.Colors.primaryText)
                                Text(plan.venue)
                                    .font(.caption)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                Text(plan.scheduledAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(Theme.Colors.accentCoral)
                            }
                            Spacer()
                            DatePlanStatusBadge(status: plan.typedStatus)
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                                .stroke(Theme.Colors.divider, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private var deleteSection: some View {
        Button(role: .destructive) {
            isShowingDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Connection")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.red)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        }
        .padding(.top, Theme.Spacing.md)
    }
    
    // MARK: - Actions
    
    private func updateStatus(_ newStatus: ConnectionStatus) {
        connection.typedStatus = newStatus
        do {
            try modelContext.save()
            successMessage = "Status changed to \(newStatus.rawValue)."
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
        }
    }
    
    private func deleteConnection() {
        modelContext.delete(connection)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to delete connection: \(error.localizedDescription)"
        }
    }
    
    private func banner(message: String, isError: Bool) -> some View {
        HStack {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : Theme.Colors.sage)
            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundColor(isError ? .red : Theme.Colors.primaryText)
        }
        .padding(Theme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isError ? Color.red.opacity(0.1) : Theme.Colors.sage.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
    }
}
