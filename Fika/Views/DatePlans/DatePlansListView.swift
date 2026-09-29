//
//  DatePlansListView.swift
//  Common Ground
//
//  List view for planned dates, grouped into upcoming and past, with create and delete actions
//

import SwiftUI
import SwiftData

struct DatePlansListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Live SwiftData query for date plans sorted chronologically
    @Query(sort: \DatePlan.scheduledAt, order: .forward)
    private var allDatePlans: [DatePlan]
    
    @Query
    private var connections: [Connection]
    
    @State private var isShowingCreateSheet: Bool = CommandLine.arguments.contains("-createPlan")
    @State private var planToDelete: DatePlan? = nil
    @State private var isShowingDeleteAlert: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    private var upcomingPlans: [DatePlan] {
        allDatePlans.filter { $0.isUpcoming && $0.typedStatus != .completed && $0.typedStatus != .canceled }
    }
    
    private var pastAndCompletedPlans: [DatePlan] {
        allDatePlans.filter { !$0.isUpcoming || $0.typedStatus == .completed || $0.typedStatus == .canceled }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let error = errorMessage {
                    banner(message: error, isError: true)
                }
                if let success = successMessage {
                    banner(message: success, isError: false)
                }
                
                if allDatePlans.isEmpty {
                    Spacer()
                    EmptyStateCard(
                        iconName: "calendar.badge.clock",
                        title: "No Date Plans Yet",
                        message: connections.isEmpty
                            ? "Save a connection in Discover first, then come back here to schedule an intentional date."
                            : "Turn shared interests into real-world moments. Schedule your first date plan.",
                        actionTitle: connections.isEmpty ? nil : "Schedule a Date",
                        action: connections.isEmpty ? nil : {
                            isShowingCreateSheet = true
                        }
                    )
                    Spacer()
                } else {
                    List {
                        if !upcomingPlans.isEmpty {
                            Section {
                                ForEach(upcomingPlans) { plan in
                                    NavigationLink {
                                        DatePlanDetailView(plan: plan)
                                    } label: {
                                        datePlanRow(plan: plan)
                                    }
                                    .listRowBackground(Theme.Colors.cardBackground)
                                    .listRowSeparatorTint(Theme.Colors.divider)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            planToDelete = plan
                                            isShowingDeleteAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            } header: {
                                Text("Upcoming (\(upcomingPlans.count))")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(Theme.Colors.accentCoral)
                            }
                        }
                        
                        if !pastAndCompletedPlans.isEmpty {
                            Section {
                                ForEach(pastAndCompletedPlans) { plan in
                                    NavigationLink {
                                        DatePlanDetailView(plan: plan)
                                    } label: {
                                        datePlanRow(plan: plan)
                                    }
                                    .listRowBackground(Theme.Colors.cardBackground)
                                    .listRowSeparatorTint(Theme.Colors.divider)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            planToDelete = plan
                                            isShowingDeleteAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            } header: {
                                Text("Past & Concluded (\(pastAndCompletedPlans.count))")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Date Plans")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.bold))
                            .foregroundColor(connections.isEmpty ? Theme.Colors.secondaryText : Theme.Colors.accentCoral)
                    }
                    .disabled(connections.isEmpty)
                    .accessibilityLabel("Create new date plan")
                }
            }
            .sheet(isPresented: $isShowingCreateSheet) {
                DatePlanFormView()
            }
            .alert("Delete Date Plan?", isPresented: $isShowingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let plan = planToDelete {
                        deletePlan(plan)
                    }
                }
                Button("Cancel", role: .cancel) {
                    planToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this date plan?")
            }
        }
    }
    
    // MARK: - Row Subview
    
    private func datePlanRow(plan: DatePlan) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            // Date calendar icon chip
            VStack(spacing: 2) {
                Text(plan.scheduledAt.formatted(.dateTime.month(.abbreviated)).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.Colors.accentCoral)
                Text(plan.scheduledAt.formatted(.dateTime.day()))
                    .font(.title3.weight(.bold))
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .frame(width: 48, height: 48)
            .background(Theme.Colors.secondaryCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(plan.activity)
                        .font(.headline)
                        .fontDesign(.serif)
                        .foregroundColor(Theme.Colors.primaryText)
                    Spacer()
                    DatePlanStatusBadge(status: plan.typedStatus)
                }
                
                if let name = plan.connection?.profile?.displayName {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.Colors.secondaryText)
                        Text("With \(name)")
                            .font(.caption.weight(.medium))
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text(plan.venue)
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Text(plan.scheduledAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
    
    private func deletePlan(_ plan: DatePlan) {
        modelContext.delete(plan)
        do {
            try modelContext.save()
            successMessage = "Date plan removed."
            planToDelete = nil
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
        .padding(.horizontal, Theme.Spacing.md)
    }
}
