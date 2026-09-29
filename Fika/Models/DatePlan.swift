//
//  DatePlan.swift
//  Common Ground
//
//  Created for SwiftData Persistence Demonstration
//

import Foundation
import SwiftData

enum DatePlanStatus: String, CaseIterable, Codable, Identifiable {
    case proposed = "Proposed"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case canceled = "Canceled"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .proposed:
            return "questionmark.circle.fill"
        case .confirmed:
            return "checkmark.circle.fill"
        case .completed:
            return "flag.checkered.circle.fill"
        case .canceled:
            return "xmark.circle.fill"
        }
    }
}

@Model
final class DatePlan {
    var id: UUID = UUID()
    var activity: String = ""
    var venue: String = ""
    var scheduledAt: Date = Date()
    var notes: String = ""
    var status: String = DatePlanStatus.proposed.rawValue
    
    // Inverse relationship to the Connection
    var connection: Connection?
    
    init(
        id: UUID = UUID(),
        activity: String,
        venue: String,
        scheduledAt: Date,
        notes: String = "",
        status: String = DatePlanStatus.proposed.rawValue,
        connection: Connection? = nil
    ) {
        self.id = id
        self.activity = activity
        self.venue = venue
        self.scheduledAt = scheduledAt
        self.notes = notes
        self.status = status
        self.connection = connection
    }
    
    var typedStatus: DatePlanStatus {
        get {
            DatePlanStatus(rawValue: status) ?? .proposed
        }
        set {
            status = newValue.rawValue
        }
    }
    
    var isUpcoming: Bool {
        scheduledAt >= Calendar.current.startOfDay(for: Date())
    }
    
    static func validate(activity: String, venue: String, scheduledAt: Date) -> String? {
        let trimmedActivity = activity.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedActivity.isEmpty {
            return "Please enter a date activity (e.g. 'Coffee & Art Gallery')."
        }
        let trimmedVenue = venue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedVenue.isEmpty {
            return "Please specify a venue or meeting location."
        }
        return nil
    }
}
