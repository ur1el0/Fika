//
//  DataSeeder.swift
//  Common Ground
//
//  Seeds fictional demo profiles once on first launch and provides reset utilities
//

import Foundation
import SwiftData

@MainActor
final class DataSeeder {
    static let availableInterests: [String] = [
        "Specialty Coffee",
        "Indie Bookstores",
        "Analog Photography",
        "Botanical Gardens",
        "Art Museum Crawls",
        "Trail Hiking",
        "Pottery & Ceramics",
        "Jazz Vinyl",
        "Home Cooking",
        "Acoustic Live Music",
        "Bouldering",
        "Mid-Century Design",
        "Independent Cinema",
        "Board Game Nights"
    ]
    
    static let relationshipIntentions: [String] = [
        "Intentional dating",
        "Long-term partnership",
        "Meaningful companionship",
        "Marriage-minded"
    ]
    
    /// Seeds fictional profiles only once if no non-current-user profiles exist.
    static func seedIfNeeded(context: ModelContext) {
        if CommandLine.arguments.contains("-demoMode") {
            seedFullDemoEnvironment(context: context)
            return
        }
        
        let descriptor = FetchDescriptor<DatingProfile>(
            predicate: #Predicate<DatingProfile> { !$0.isCurrentUser }
        )
        
        do {
            let existing = try context.fetch(descriptor)
            let hasNewProfiles = existing.contains(where: { $0.displayName == "Kurt Laja" })
            if existing.isEmpty || !hasNewProfiles {
                // Delete old outdated fictional profiles if any
                for old in existing {
                    context.delete(old)
                }
                insertFictionalProfiles(context: context)
                try context.save()
            }
        } catch {
            print("Failed to check or seed fictional profiles: \(error.localizedDescription)")
        }
    }
    
    /// Seeds an end-to-end demo dataset including currentUser, connections, and date plans
    static func seedFullDemoEnvironment(context: ModelContext) {
        do {
            let userDesc = FetchDescriptor<DatingProfile>(
                predicate: #Predicate<DatingProfile> { $0.isCurrentUser }
            )
            let existingUser = try context.fetch(userDesc)
            let currentUser: DatingProfile
            if let first = existingUser.first {
                currentUser = first
            } else {
                currentUser = DatingProfile(
                    displayName: "Elena Rostova",
                    age: 26,
                    city: "Portland, OR",
                    bio: "Ceramics artist and collector of vintage botanical prints. Looking for calm coffee chats, slow Sunday mornings, and thoughtful bookstore wanders.",
                    relationshipIntent: "Intentional dating",
                    interests: ["Specialty Coffee", "Indie Bookstores", "Pottery & Ceramics", "Botanical Gardens"],
                    preferredFirstDateActivity: "Pour-over tasting and antiquarian bookstore browse",
                    isCurrentUser: true
                )
                context.insert(currentUser)
            }
            
            let profilesDesc = FetchDescriptor<DatingProfile>(
                predicate: #Predicate<DatingProfile> { !$0.isCurrentUser }
            )
            var fictional = try context.fetch(profilesDesc)
            if fictional.isEmpty || !fictional.contains(where: { $0.displayName == "Ron Vincent Cada" }) {
                for old in fictional {
                    context.delete(old)
                }
                insertFictionalProfiles(context: context)
                try context.save()
                fictional = try context.fetch(profilesDesc)
            }
            
            let connDesc = FetchDescriptor<Connection>()
            let existingConns = try context.fetch(connDesc)
            if existingConns.isEmpty,
               let kurt = fictional.first(where: { $0.displayName.contains("Kurt") }),
               let mike = fictional.first(where: { $0.displayName.contains("Mike") }) {
                let conn1 = Connection(
                    status: ConnectionStatus.saved.rawValue,
                    createdAt: Date().addingTimeInterval(-86400 * 2),
                    profile: kurt
                )
                let conn2 = Connection(
                    status: ConnectionStatus.planningDate.rawValue,
                    createdAt: Date().addingTimeInterval(-86400),
                    profile: mike
                )
                context.insert(conn1)
                context.insert(conn2)
                
                let plan1 = DatePlan(
                    activity: "Board Games & Pour-Over",
                    venue: "The Daily Grind Cafe",
                    scheduledAt: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                    notes: "Meeting at the corner table by 3 PM.",
                    status: DatePlanStatus.confirmed.rawValue,
                    connection: conn2
                )
                context.insert(plan1)
            }
            
            try context.save()
        } catch {
            print("Failed to seed full demo environment: \(error.localizedDescription)")
        }
    }
    
    /// Inserts the standard set of fictional demo profiles.
    static func insertFictionalProfiles(context: ModelContext) {
        let baseTime = Date(timeIntervalSince1970: 1700000000)
        let profiles = [
            DatingProfile(
                displayName: "Kurt Laja",
                age: 25,
                city: "Lucena City",
                bio: "Coffee enthusiast and photographer. Love quiet cafe mornings, 35mm film, and weekend trail runs.",
                relationshipIntent: "Intentional dating",
                interests: ["Specialty Coffee", "Analog Photography", "Indie Bookstores", "Trail Hiking"],
                preferredFirstDateActivity: "Espresso tasting and visiting an indie bookstore.",
                isCurrentUser: false,
                createdAt: baseTime.addingTimeInterval(100)
            ),
            DatingProfile(
                displayName: "Ron Vincent Cada",
                age: 26,
                city: "Quezon Province",
                bio: "Music lover and reader. I enjoy vinyl record hunting, art galleries, and peaceful evening walks.",
                relationshipIntent: "Meaningful companionship",
                interests: ["Jazz Vinyl", "Art Museum Crawls", "Acoustic Live Music", "Indie Bookstores"],
                preferredFirstDateActivity: "Checking out vinyl records followed by a casual dinner.",
                isCurrentUser: false,
                createdAt: baseTime.addingTimeInterval(200)
            ),
            DatingProfile(
                displayName: "Mike Andrei Gomez",
                age: 24,
                city: "Tayabas City",
                bio: "Tech student and cyclist. Big fan of board game nights, good comfort food, and acoustic music.",
                relationshipIntent: "Long-term partnership",
                interests: ["Board Game Nights", "Acoustic Live Music", "Home Cooking", "Specialty Coffee"],
                preferredFirstDateActivity: "Playing casual board games over iced coffee.",
                isCurrentUser: false,
                createdAt: baseTime.addingTimeInterval(300)
            ),
            DatingProfile(
                displayName: "Julian Thorne",
                age: 27,
                city: "Portland, OR",
                bio: "Architectural designer. Spends weekends sketching historic buildings and finding vintage prints.",
                relationshipIntent: "Long-term partnership",
                interests: ["Mid-Century Design", "Analog Photography", "Specialty Coffee"],
                preferredFirstDateActivity: "Exploring historic architecture and grabbing pour-over coffee.",
                isCurrentUser: false,
                createdAt: baseTime.addingTimeInterval(400)
            ),
            DatingProfile(
                displayName: "Maya Lin-Chen",
                age: 26,
                city: "Seattle, WA",
                bio: "Greenhouse tender and baker. Enjoys coastal nature walks and baking sourdough bread.",
                relationshipIntent: "Intentional dating",
                interests: ["Botanical Gardens", "Home Cooking", "Pottery & Ceramics", "Trail Hiking"],
                preferredFirstDateActivity: "A slow stroll through a botanical greenhouse and herbal tea.",
                isCurrentUser: false,
                createdAt: baseTime.addingTimeInterval(500)
            ),
            DatingProfile(
                displayName: "Priya Patel",
                age: 28,
                city: "Chicago, IL",
                bio: "Museum archivist. Passionate about pottery throwing, textile crafts, and farmer's markets.",
                relationshipIntent: "Intentional dating",
                interests: ["Art Museum Crawls", "Pottery & Ceramics", "Botanical Gardens"],
                preferredFirstDateActivity: "Browsing a ceramics exhibition followed by fresh pasta.",
                isCurrentUser: false,
                createdAt: baseTime.addingTimeInterval(600)
            )
        ]
        
        for profile in profiles {
            context.insert(profile)
        }
    }
    
    /// Resets all demo profiles and connections back to initial seed state.
    static func resetToInitialSeed(context: ModelContext) {
        do {
            // Delete all DatePlans
            let plans = try context.fetch(FetchDescriptor<DatePlan>())
            for plan in plans { context.delete(plan) }
            
            // Delete all Connections
            let connections = try context.fetch(FetchDescriptor<Connection>())
            for connection in connections { context.delete(connection) }
            
            // Delete all non-current-user profiles
            let profiles = try context.fetch(FetchDescriptor<DatingProfile>(
                predicate: #Predicate<DatingProfile> { !$0.isCurrentUser }
            ))
            for profile in profiles { context.delete(profile) }
            
            // Insert fresh demo profiles
            insertFictionalProfiles(context: context)
            
            try context.save()
        } catch {
            print("Failed to reset demo data: \(error.localizedDescription)")
        }
    }
}
