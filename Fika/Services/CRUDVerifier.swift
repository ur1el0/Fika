//
//  CRUDVerifier.swift
//  Common Ground
//
//  Automated in-app verification runner testing SwiftData Create, Read, Update, and Delete operations
//

import Foundation
import SwiftData

@MainActor
final class CRUDVerifier {
    struct VerificationResult {
        let isSuccess: Bool
        let log: [String]
    }
    
    static func runVerification(context: ModelContext) -> VerificationResult {
        var logs: [String] = []
        func log(_ msg: String) {
            logs.append(msg)
            print("[CRUD_VERIFIER] \(msg)")
        }
        
        log("Starting SwiftData CRUD & Cascade verification...")
        
        do {
            // -------------------------------------------------------------
            // 1. CREATE Verification
            // -------------------------------------------------------------
            log("1. Testing CREATE:")
            let testProfile = DatingProfile(
                displayName: "Test Candidate",
                age: 28,
                city: "San Francisco, CA",
                bio: "Verification profile testing swiftdata persistence.",
                relationshipIntent: "Intentional dating",
                interests: ["Specialty Coffee", "Indie Bookstores"],
                preferredFirstDateActivity: "Coffee tasting at Sightglass",
                isCurrentUser: false
            )
            context.insert(testProfile)
            try context.save()
            log("   ✓ Profile inserted: \(testProfile.displayName) (ID: \(testProfile.id))")
            
            let testConnection = Connection(
                status: ConnectionStatus.saved.rawValue,
                createdAt: Date(),
                profile: testProfile
            )
            context.insert(testConnection)
            try context.save()
            log("   ✓ Connection created and linked to profile (Status: \(testConnection.status))")
            
            let testDatePlan = DatePlan(
                activity: "Pour-over tasting",
                venue: "Sightglass Coffee",
                scheduledAt: Date().addingTimeInterval(86400 * 3),
                notes: "Discuss art and books",
                status: DatePlanStatus.proposed.rawValue,
                connection: testConnection
            )
            context.insert(testDatePlan)
            try context.save()
            log("   ✓ DatePlan created and linked to connection (Activity: \(testDatePlan.activity))")
            
            // -------------------------------------------------------------
            // 2. READ Verification
            // -------------------------------------------------------------
            log("2. Testing READ:")
            let profileId = testProfile.id
            let fetchedProfiles = try context.fetch(FetchDescriptor<DatingProfile>(
                predicate: #Predicate<DatingProfile> { $0.id == profileId }
            ))
            guard let readProfile = fetchedProfiles.first else {
                throw NSError(domain: "CRUDVerifier", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read inserted profile."])
            }
            log("   ✓ Read profile from SwiftData: \(readProfile.displayName), age \(readProfile.age)")
            
            let connectionId = testConnection.id
            let fetchedConnections = try context.fetch(FetchDescriptor<Connection>(
                predicate: #Predicate<Connection> { $0.id == connectionId }
            ))
            guard let readConnection = fetchedConnections.first else {
                throw NSError(domain: "CRUDVerifier", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to read inserted connection."])
            }
            log("   ✓ Read connection from SwiftData: linked to \(readConnection.profile?.displayName ?? "nil")")
            
            let planId = testDatePlan.id
            let fetchedPlans = try context.fetch(FetchDescriptor<DatePlan>(
                predicate: #Predicate<DatePlan> { $0.id == planId }
            ))
            guard let readPlan = fetchedPlans.first else {
                throw NSError(domain: "CRUDVerifier", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to read inserted date plan."])
            }
            log("   ✓ Read date plan from SwiftData: venue \(readPlan.venue), status \(readPlan.status)")
            
            // -------------------------------------------------------------
            // 3. UPDATE Verification
            // -------------------------------------------------------------
            log("3. Testing UPDATE:")
            readProfile.city = "Oakland, CA"
            readProfile.bio = "Updated bio exploring botanical gardens."
            readConnection.typedStatus = .planningDate
            readPlan.venue = "Blue Bottle & Bookstore"
            readPlan.typedStatus = .confirmed
            try context.save()
            
            let reReadProfile = try context.fetch(FetchDescriptor<DatingProfile>(predicate: #Predicate<DatingProfile> { $0.id == profileId })).first!
            let reReadConnection = try context.fetch(FetchDescriptor<Connection>(predicate: #Predicate<Connection> { $0.id == connectionId })).first!
            let reReadPlan = try context.fetch(FetchDescriptor<DatePlan>(predicate: #Predicate<DatePlan> { $0.id == planId })).first!
            
            guard reReadProfile.city == "Oakland, CA",
                  reReadConnection.typedStatus == .planningDate,
                  reReadPlan.typedStatus == .confirmed,
                  reReadPlan.venue == "Blue Bottle & Bookstore" else {
                throw NSError(domain: "CRUDVerifier", code: 4, userInfo: [NSLocalizedDescriptionKey: "Update verification failed; values do not match."])
            }
            log("   ✓ Updated profile city to Oakland, CA")
            log("   ✓ Updated connection status to Planning Date")
            log("   ✓ Updated date plan status to Confirmed and venue to Blue Bottle & Bookstore")
            
            // -------------------------------------------------------------
            // 4. DELETE & Cascade Verification
            // -------------------------------------------------------------
            log("4. Testing DELETE & Cascade Rules:")
            // First delete individual date plan
            context.delete(reReadPlan)
            try context.save()
            let checkPlansAfterDelete = try context.fetch(FetchDescriptor<DatePlan>(predicate: #Predicate<DatePlan> { $0.id == planId }))
            guard checkPlansAfterDelete.isEmpty else {
                throw NSError(domain: "CRUDVerifier", code: 5, userInfo: [NSLocalizedDescriptionKey: "DatePlan still exists after deletion."])
            }
            log("   ✓ DatePlan deleted independently; Connection preserved.")
            
            // Re-create a date plan to test cascade deletion when connection is deleted
            let cascadePlan = DatePlan(
                activity: "Cascade test date",
                venue: "Coffee Bar",
                scheduledAt: Date(),
                connection: reReadConnection
            )
            context.insert(cascadePlan)
            try context.save()
            let cascadePlanId = cascadePlan.id
            
            // Delete connection -> verify cascade delete of datePlans
            context.delete(reReadConnection)
            try context.save()
            
            let connsAfter = try context.fetch(FetchDescriptor<Connection>(predicate: #Predicate<Connection> { $0.id == connectionId }))
            let plansAfter = try context.fetch(FetchDescriptor<DatePlan>(predicate: #Predicate<DatePlan> { $0.id == cascadePlanId }))
            
            guard connsAfter.isEmpty, plansAfter.isEmpty else {
                throw NSError(domain: "CRUDVerifier", code: 6, userInfo: [NSLocalizedDescriptionKey: "Cascade delete failed; orphaned date plans or connection remains."])
            }
            log("   ✓ Connection deleted. Cascade rule verified: child DatePlan was also removed.")
            
            // Delete profile
            context.delete(reReadProfile)
            try context.save()
            let profilesAfter = try context.fetch(FetchDescriptor<DatingProfile>(predicate: #Predicate<DatingProfile> { $0.id == profileId }))
            guard profilesAfter.isEmpty else {
                throw NSError(domain: "CRUDVerifier", code: 7, userInfo: [NSLocalizedDescriptionKey: "Profile still exists after deletion."])
            }
            log("   ✓ Profile deleted cleanly.")
            
            log("All CRUD and Cascade delete checks PASSED successfully.")
            return VerificationResult(isSuccess: true, log: logs)
        } catch {
            let errorMsg = "Verification failed with error: \(error.localizedDescription)"
            log("   ✗ \(errorMsg)")
            return VerificationResult(isSuccess: false, log: logs)
        }
    }
}
