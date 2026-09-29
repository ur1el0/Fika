//
//  DatePlanFormView.swift
//  Common Ground
//
//  Form for creating or editing a DatePlan with validation and persistence
//

import SwiftUI
import SwiftData

struct DatePlanFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Optional preset connection (when opened from ConnectionDetail)
    var connection: Connection? = nil
    // Optional plan to edit (when editing existing)
    var planToEdit: DatePlan? = nil
    
    // Live query of all connections to allow choosing connection if not preset
    @Query(sort: \Connection.createdAt, order: .reverse)
    private var allConnections: [Connection]
    
    @State private var viewModel = DatePlanViewModel()
    
    var isEditing: Bool {
        planToEdit != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(isEditing ? "EDIT DATE PLAN" : "SCHEDULE A DATE")
                            .font(.caption2.weight(.bold))
                            .tracking(1.2)
                            .foregroundColor(Theme.Colors.accentCoral)
                        
                        Text(isEditing ? "Update Details" : "Plan Common Ground")
                            .font(.title2.weight(.semibold))
                            .fontDesign(.serif)
                            .foregroundColor(Theme.Colors.primaryText)
                    }
                    
                    if let err = viewModel.validationError {
                        banner(message: err, isError: true)
                    }
                    if let err = viewModel.errorMessage {
                        banner(message: err, isError: true)
                    }
                    
                    // Connection Picker Section (if not editing and no pre-passed connection)
                    connectionSection
                    
                    // Details Section
                    detailsSection
                    
                    // Timing Section
                    timingSection
                    
                    // Status Section
                    statusSection
                    
                    // Notes Section
                    notesSection
                    
                    // Save Button
                    Button {
                        if viewModel.savePlan(context: modelContext) {
                            dismiss()
                        }
                    } label: {
                        Text(isEditing ? "Save Changes" : "Create Date Plan")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, Theme.Spacing.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            .onAppear {
                if let plan = planToEdit {
                    viewModel.prepareForEdit(plan: plan)
                } else {
                    viewModel.prepareForNew(connection: connection ?? allConnections.first)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("WITH CONNECTION")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            if isEditing || connection != nil {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Theme.Colors.accentCoral)
                    Text(viewModel.selectedConnection?.profile?.displayName ?? "Unknown Profile")
                        .font(.body.weight(.medium))
                        .foregroundColor(Theme.Colors.primaryText)
                    Spacer()
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                        .stroke(Theme.Colors.divider, lineWidth: 1)
                )
            } else {
                Picker("Connection", selection: $viewModel.selectedConnection) {
                    ForEach(allConnections) { conn in
                        Text(conn.profile?.displayName ?? "Connection").tag(conn as Connection?)
                    }
                }
                .pickerStyle(.menu)
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
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("ACTIVITY")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("e.g. Specialty Coffee & Antiquarian Books", text: $viewModel.activity)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("VENUE / LOCATION")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("e.g. Blue Heron Coffee & Books, Arts District", text: $viewModel.venue)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
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
    
    private var timingSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("DATE & TIME")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            DatePicker(
                "Scheduled At",
                selection: $viewModel.scheduledAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("STATUS")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Picker("Plan Status", selection: $viewModel.status) {
                ForEach(DatePlanStatus.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }
            .pickerStyle(.segmented)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("NOTES & REMINDERS")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            TextField(
                "e.g. Meeting outside front entrance at 3pm. Bring film cameras.",
                text: $viewModel.notes,
                axis: .vertical
            )
            .lineLimit(2...4)
            .font(.body)
            .foregroundColor(Theme.Colors.primaryText)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
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
