//
//  ConnectionsListView.swift
//  Common Ground
//
//  List view for saved connections with filtering, status updates, and cascade deletion
//

import SwiftUI
import SwiftData

struct ConnectionsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Live SwiftData query for connections, newest first
    @Query(sort: \Connection.createdAt, order: .reverse)
    private var allConnections: [Connection]
    
    @State private var viewModel = ConnectionViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                headerFilters
                
                // Feedback / Error banners
                if let error = viewModel.errorMessage {
                    feedbackBanner(message: error, isError: true)
                }
                if let success = viewModel.successMessage {
                    feedbackBanner(message: success, isError: false)
                }
                
                let filtered = viewModel.filterConnections(allConnections)
                
                if filtered.isEmpty {
                    Spacer()
                    EmptyStateCard(
                        iconName: "bookmark",
                        title: allConnections.isEmpty ? "No Connections Yet" : "No Matches",
                        message: allConnections.isEmpty
                            ? "Explore Discover to find profiles that share common ground with you and save them here."
                            : "No connections match your current search or filter."
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filtered) { connection in
                            NavigationLink {
                                ConnectionDetailView(connection: connection)
                            } label: {
                                connectionRow(connection: connection)
                            }
                            .listRowBackground(Theme.Colors.cardBackground)
                            .listRowSeparatorTint(Theme.Colors.divider)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.confirmDelete(connection: connection)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Connections")
            .confirmationDialog(
                "Delete Connection?",
                isPresented: $viewModel.isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Connection & Date Plans", role: .destructive) {
                    viewModel.performDelete(context: modelContext)
                }
                Button("Cancel", role: .cancel) {
                    viewModel.connectionToDelete = nil
                }
            } message: {
                if let name = viewModel.connectionToDelete?.profile?.displayName {
                    Text("Are you sure you want to remove \(name)? Any date plans created with this profile will also be deleted.")
                } else {
                    Text("Are you sure you want to delete this connection?")
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerFilters: some View {
        VStack(spacing: Theme.Spacing.xs) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("Search connections by name or city...", text: $viewModel.searchText)
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.primaryText)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
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
            
            // Status Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.xs) {
                    InterestTagPill(
                        title: "All (\(allConnections.count))",
                        isSelected: viewModel.selectedStatusFilter == nil,
                        action: {
                            withAnimation { viewModel.selectedStatusFilter = nil }
                        }
                    )
                    
                    ForEach(ConnectionStatus.allCases) { status in
                        let count = allConnections.filter { $0.typedStatus == status }.count
                        InterestTagPill(
                            title: "\(status.rawValue) (\(count))",
                            isSelected: viewModel.selectedStatusFilter == status,
                            action: {
                                withAnimation { viewModel.selectedStatusFilter = status }
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
    
    private func connectionRow(connection: Connection) -> some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            // Profile avatar placeholder
            AvatarPlaceholderView(
                name: connection.profile?.displayName ?? "Connection",
                size: 46,
                showBadge: false
            )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(connection.profile?.displayName ?? "Unknown Profile")
                        .font(.headline)
                        .fontDesign(.serif)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    if let age = connection.profile?.age {
                        Text("\(age)")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    ConnectionStatusBadge(status: connection.typedStatus)
                }
                
                if let city = connection.profile?.city {
                    Text(city)
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                let planCount = connection.datePlans?.count ?? 0
                if planCount > 0 {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(Theme.Colors.ochre)
                        Text("\(planCount) date plan\(planCount == 1 ? "" : "s")")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(Theme.Colors.ochre)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
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
                viewModel.errorMessage = nil
                viewModel.successMessage = nil
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
    }
}
