//
//  DatePlanDetailView.swift
//  Common Ground
//
//  Detailed view of a DatePlan: view details, update status, edit, or delete
//

import SwiftUI
import SwiftData

struct DatePlanDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var plan: DatePlan
    
    @State private var isShowingEditSheet: Bool = false
    @State private var isShowingDeleteAlert: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header card
                headerCard
                
                if let error = errorMessage {
                    banner(message: error, isError: true)
                }
                if let success = successMessage {
                    banner(message: success, isError: false)
                }
                
                // Status Switcher
                statusSwitcherCard
                
                // Venue and Time Details
                detailsCard
                
                // Notes Section
                if !plan.notes.isEmpty {
                    notesCard
                }
                
                // Connection Info
                if let connection = plan.connection {
                    connectionCard(connection: connection)
                }
                
                // Actions: Edit and Delete
                actionButtons
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.lg)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle("Date Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
                .foregroundColor(Theme.Colors.accentCoral)
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            DatePlanFormView(connection: plan.connection, planToEdit: plan)
        }
        .alert("Delete Date Plan?", isPresented: $isShowingDeleteAlert) {
            Button("Delete Plan", role: .destructive) {
                deletePlan()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this date plan? The connection itself will remain.")
        }
    }
    
    // MARK: - Subviews
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("ACTIVITY")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundColor(Theme.Colors.accentCoral)
                
                Spacer()
                
                DatePlanStatusBadge(status: plan.typedStatus)
            }
            
            Text(plan.activity)
                .font(.title2.weight(.semibold))
                .fontDesign(.serif)
                .foregroundColor(Theme.Colors.primaryText)
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
    
    private var statusSwitcherCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("UPDATE STATUS")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Picker("Status", selection: Binding(
                get: { plan.typedStatus },
                set: { newStatus in
                    updateStatus(newStatus)
                }
            )) {
                ForEach(DatePlanStatus.allCases) { status in
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
    
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title3)
                    .foregroundColor(Theme.Colors.accentCoral)
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("VENUE")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text(plan.venue)
                        .font(.body.weight(.medium))
                        .foregroundColor(Theme.Colors.primaryText)
                }
            }
            
            Divider().background(Theme.Colors.divider)
            
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundColor(Theme.Colors.ochre)
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("DATE & TIME")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text(plan.scheduledAt.formatted(date: .complete, time: .shortened))
                        .font(.body.weight(.medium))
                        .foregroundColor(Theme.Colors.primaryText)
                }
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
    
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text("NOTES")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            Text(plan.notes)
                .font(.body)
                .foregroundColor(Theme.Colors.primaryText)
                .lineSpacing(2)
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
    
    private func connectionCard(connection: Connection) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("PLANNED WITH")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(connection.profile?.displayName ?? "Connection")
                        .font(.headline)
                        .foregroundColor(Theme.Colors.primaryText)
                    if let city = connection.profile?.city {
                        Text(city)
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                Spacer()
                ConnectionStatusBadge(status: connection.typedStatus)
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
    
    private var actionButtons: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Button {
                isShowingEditSheet = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Date Plan")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button(role: .destructive) {
                isShowingDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Date Plan")
                }
                .font(.headline)
                .foregroundColor(.red)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            }
        }
        .padding(.top, Theme.Spacing.md)
    }
    
    // MARK: - Actions
    
    private func updateStatus(_ newStatus: DatePlanStatus) {
        plan.typedStatus = newStatus
        do {
            try modelContext.save()
            successMessage = "Date plan marked as \(newStatus.rawValue)."
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
        }
    }
    
    private func deletePlan() {
        modelContext.delete(plan)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to delete plan: \(error.localizedDescription)"
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
