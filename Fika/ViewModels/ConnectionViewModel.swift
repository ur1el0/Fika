//
//  ConnectionViewModel.swift
//  Common Ground
//
//  Manages the Connections list, status updates, and cascade deletion
//

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
final class ConnectionViewModel {
    var selectedStatusFilter: ConnectionStatus? = nil
    var searchText: String = ""
    var errorMessage: String? = nil
    var successMessage: String? = nil
    
    // Deletion confirmation state
    var connectionToDelete: Connection? = nil
    var isShowingDeleteConfirmation: Bool = false
    
    // Date plan sheet state
    var connectionForNewDatePlan: Connection? = nil
    
    func filterConnections(_ connections: [Connection]) -> [Connection] {
        connections.filter { conn in
            if let filter = selectedStatusFilter {
                if conn.typedStatus != filter {
                    return false
                }
            }
            
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let query = searchText.lowercased()
                let name = conn.profile?.displayName.lowercased() ?? ""
                let city = conn.profile?.city.lowercased() ?? ""
                let status = conn.status.lowercased()
                if !(name.contains(query) || city.contains(query) || status.contains(query)) {
                    return false
                }
            }
            
            return true
        }
    }
    
    func updateStatus(connection: Connection, newStatus: ConnectionStatus, context: ModelContext) {
        errorMessage = nil
        successMessage = nil
        
        connection.typedStatus = newStatus
        
        do {
            try context.save()
            successMessage = "Status updated to \(newStatus.rawValue)."
        } catch {
            errorMessage = "Failed to update connection status: \(error.localizedDescription)"
        }
    }
    
    func confirmDelete(connection: Connection) {
        connectionToDelete = connection
        isShowingDeleteConfirmation = true
    }
    
    func performDelete(context: ModelContext) {
        guard let connection = connectionToDelete else { return }
        errorMessage = nil
        
        let profileName = connection.profile?.displayName ?? "Connection"
        context.delete(connection)
        
        do {
            try context.save()
            successMessage = "Removed \(profileName) and associated date plans."
            connectionToDelete = nil
            isShowingDeleteConfirmation = false
        } catch {
            errorMessage = "Failed to delete connection: \(error.localizedDescription)"
        }
    }
}
