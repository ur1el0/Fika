//
//  DatePlanViewModel.swift
//  Common Ground
//
//  Manages Date Plan creation, editing, status changes, and deletion
//

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
final class DatePlanViewModel {
    // Form state
    var activity: String = ""
    var venue: String = ""
    var scheduledAt: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    var notes: String = ""
    var status: DatePlanStatus = .proposed
    var selectedConnection: Connection? = nil
    
    // UI Feedback state
    var validationError: String? = nil
    var errorMessage: String? = nil
    var successMessage: String? = nil
    
    // Sheet presentation state
    var isPresentingForm: Bool = false
    var planToEdit: DatePlan? = nil
    
    // Deletion confirmation state
    var planToDelete: DatePlan? = nil
    var isShowingDeleteConfirmation: Bool = false
    
    func prepareForNew(connection: Connection? = nil) {
        planToEdit = nil
        selectedConnection = connection
        activity = connection?.profile?.preferredFirstDateActivity ?? ""
        venue = ""
        scheduledAt = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        notes = ""
        status = .proposed
        validationError = nil
        errorMessage = nil
        isPresentingForm = true
    }
    
    func prepareForEdit(plan: DatePlan) {
        planToEdit = plan
        selectedConnection = plan.connection
        activity = plan.activity
        venue = plan.venue
        scheduledAt = plan.scheduledAt
        notes = plan.notes
        status = plan.typedStatus
        validationError = nil
        errorMessage = nil
        isPresentingForm = true
    }
    
    func savePlan(context: ModelContext) -> Bool {
        validationError = nil
        errorMessage = nil
        
        if let err = DatePlan.validate(activity: activity, venue: venue, scheduledAt: scheduledAt) {
            validationError = err
            return false
        }
        
        guard let connection = selectedConnection else {
            validationError = "Please select a connection for this date plan."
            return false
        }
        
        if let plan = planToEdit {
            // Update existing
            plan.activity = activity.trimmingCharacters(in: .whitespacesAndNewlines)
            plan.venue = venue.trimmingCharacters(in: .whitespacesAndNewlines)
            plan.scheduledAt = scheduledAt
            plan.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            plan.typedStatus = status
            plan.connection = connection
        } else {
            // Create new
            let newPlan = DatePlan(
                activity: activity.trimmingCharacters(in: .whitespacesAndNewlines),
                venue: venue.trimmingCharacters(in: .whitespacesAndNewlines),
                scheduledAt: scheduledAt,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                status: status.rawValue,
                connection: connection
            )
            context.insert(newPlan)
            
            // If connection status was "Saved", elevate it to "Planning Date" automatically!
            if connection.typedStatus == .saved {
                connection.typedStatus = .planningDate
            }
        }
        
        do {
            try context.save()
            successMessage = planToEdit == nil ? "Date plan scheduled!" : "Date plan updated!"
            isPresentingForm = false
            planToEdit = nil
            return true
        } catch {
            errorMessage = "Failed to save date plan: \(error.localizedDescription)"
            return false
        }
    }
    
    func confirmDelete(plan: DatePlan) {
        planToDelete = plan
        isShowingDeleteConfirmation = true
    }
    
    func performDelete(context: ModelContext) {
        guard let plan = planToDelete else { return }
        errorMessage = nil
        
        context.delete(plan)
        
        do {
            try context.save()
            successMessage = "Date plan removed."
            planToDelete = nil
            isShowingDeleteConfirmation = false
        } catch {
            errorMessage = "Failed to delete date plan: \(error.localizedDescription)"
        }
    }
}
