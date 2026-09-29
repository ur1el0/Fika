//
//  Connection.swift
//  Common Ground
//
//  Created for SwiftData Persistence Demonstration
//

import Foundation
import SwiftData

enum ConnectionStatus: String, CaseIterable, Codable, Identifiable {
    case saved = "Saved"
    case mutualSpark = "Mutual Spark"
    case planningDate = "Planning Date"
    case connected = "Connected"
    case archived = "Archived"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .saved:
            return "bookmark.fill"
        case .mutualSpark:
            return "sparkles"
        case .planningDate:
            return "calendar.badge.clock"
        case .connected:
            return "heart.fill"
        case .archived:
            return "archivebox.fill"
        }
    }
}

@Model
final class Connection {
    var id: UUID = UUID()
    var status: String = ConnectionStatus.saved.rawValue
    var createdAt: Date = Date()
    
    // Inverse relationship to the DatingProfile
    var profile: DatingProfile?
    
    // Explicit inverse cascade delete rule: deleting a connection cascades to its date plans
    @Relationship(deleteRule: .cascade, inverse: \DatePlan.connection)
    var datePlans: [DatePlan]? = []
    
    init(
        id: UUID = UUID(),
        status: String = ConnectionStatus.saved.rawValue,
        createdAt: Date = Date(),
        profile: DatingProfile? = nil
    ) {
        self.id = id
        self.status = status
        self.createdAt = createdAt
        self.profile = profile
        self.datePlans = []
    }
    
    var typedStatus: ConnectionStatus {
        get {
            ConnectionStatus(rawValue: status) ?? .saved
        }
        set {
            status = newValue.rawValue
        }
    }
}
