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
            guard existing.isEmpty else {
                return // Already seeded; avoid duplicate creation
            }
            
            insertFictionalProfiles(context: context)
            try context.save()
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
            if fictional.isEmpty {
                insertFictionalProfiles(context: context)
                try context.save()
                fictional = try context.fetch(profilesDesc)
            }
            
            let connDesc = FetchDescriptor<Connection>()
            let existingConns = try context.fetch(connDesc)
            if existingConns.isEmpty, let julian = fictional.first(where: { $0.displayName.contains("Julian") }),
               let maya = fictional.first(where: { $0.displayName.contains("Maya") }) {
                let conn1 = Connection(
                    status: ConnectionStatus.mutualSpark.rawValue,
                    createdAt: Date().addingTimeInterval(-86400 * 2),
                    profile: julian
                )
                let conn2 = Connection(
                    status: ConnectionStatus.planningDate.rawValue,
                    createdAt: Date().addingTimeInterval(-86400),
                    profile: maya
                )
                context.insert(conn1)
                context.insert(conn2)
                
                let plan1 = DatePlan(
                    activity: "Conservatory Stroll & Herbal Tea",
                    venue: "Volunteer Park Conservatory",
                    scheduledAt: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                    notes: "Meeting by the palm house entrance at 2 PM.",
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
    
    /// Inserts the standard set of 8 fictional demo profiles.
    static func insertFictionalProfiles(context: ModelContext) {
        let profiles = [
            DatingProfile(
                displayName: "Julian Thorne",
                age: 27,
                city: "Portland, OR",
                bio: "Architectural restorer and 35mm film photographer. Weekend mornings are for estate sales, medium-format prints, and finding old jazz records.",
                relationshipIntent: "Long-term partnership",
                interests: ["Analog Photography", "Specialty Coffee", "Mid-Century Design", "Indie Bookstores", "Jazz Vinyl"],
                preferredFirstDateActivity: "Espresso tasting followed by wandering an antiquarian bookshop.",
                isCurrentUser: false
            ),
            DatingProfile(
                displayName: "Maya Lin-Chen",
                age: 26,
                city: "Seattle, WA",
                bio: "Landscape architect fascinated by native mosses, urban greenhouses, and slow sourdough baking. I love quiet walks in drizzly weather.",
                relationshipIntent: "Intentional dating",
                interests: ["Botanical Gardens", "Home Cooking", "Trail Hiking", "Indie Bookstores", "Pottery & Ceramics"],
                preferredFirstDateActivity: "A slow stroll through the local conservatory and fresh herbal tea.",
                isCurrentUser: false
            ),
            DatingProfile(
                displayName: "Soren Lindqvist",
                age: 31,
                city: "Minneapolis, MN",
                bio: "High school literature teacher and cyclist. When not grading essays on existentialism, I'm roasting Nordic light roasts or playing acoustic folk.",
                relationshipIntent: "Long-term partnership",
                interests: ["Specialty Coffee", "Acoustic Live Music", "Bouldering", "Independent Cinema", "Board Game Nights"],
                preferredFirstDateActivity: "Pour-over at a quiet neighborhood cafe, sharing favorite passages from books.",
                isCurrentUser: false
            ),
            DatingProfile(
                displayName: "Priya Patel",
                age: 29,
                city: "Chicago, IL",
                bio: "Museum archivist and ceramicist. Drawn to ancient textile history, slow wheel throwing, and picking up heirloom tomatoes at the farmers market.",
                relationshipIntent: "Meaningful companionship",
                interests: ["Art Museum Crawls", "Pottery & Ceramics", "Home Cooking", "Botanical Gardens", "Analog Photography"],
                preferredFirstDateActivity: "Visiting a quiet ceramics studio gallery followed by handmade pasta.",
                isCurrentUser: false
            ),
            DatingProfile(
                displayName: "Leo Vance",
                age: 28,
                city: "Denver, CO",
                bio: "Sound designer for indie games. Warm analog synthesizers, bouldering problems, and baking cardamom buns on crisp Sunday mornings.",
                relationshipIntent: "Intentional dating",
                interests: ["Jazz Vinyl", "Bouldering", "Specialty Coffee", "Board Game Nights", "Trail Hiking"],
                preferredFirstDateActivity: "Browsing crate records at an independent vinyl shop and grabbing warm cider.",
                isCurrentUser: false
            ),
            DatingProfile(
                displayName: "Clara Moreau",
                age: 30,
                city: "San Francisco, CA",
                bio: "Documentary editor and printmaker. Coastal trails, Japanese woodblock prints, and long conversations that make you completely forget the time.",
                relationshipIntent: "Long-term partnership",
                interests: ["Independent Cinema", "Art Museum Crawls", "Trail Hiking", "Analog Photography", "Indie Bookstores"],
                preferredFirstDateActivity: "Browsing photography monographs at an indie press shop, then watching the fog roll in.",
                isCurrentUser: false
            ),
            DatingProfile(
                displayName: "Marcus Kim",
                age: 32,
                city: "Austin, TX",
                bio: "Urban planner with an affection for walkable avenues, mid-century furniture restoration, and fingerstyle acoustic guitar on the porch.",
                relationshipIntent: "Marriage-minded",
                interests: ["Acoustic Live Music", "Mid-Century Design", "Specialty Coffee", "Home Cooking", "Board Game Nights"],
                preferredFirstDateActivity: "Walking through a historic neighborhood listening to acoustic live music.",
                isCurrentUser: false
            ),
            DatingProfile(
                displayName: "Ananya Sen",
                age: 27,
                city: "Brooklyn, NY",
                bio: "Botanical illustrator and poetry press editor. Cozy evenings with genmaicha tea, quiet parallel reading, and jazz on low volume.",
                relationshipIntent: "Intentional dating",
                interests: ["Botanical Gardens", "Jazz Vinyl", "Indie Bookstores", "Art Museum Crawls", "Pottery & Ceramics"],
                preferredFirstDateActivity: "Sketching plants at the botanical garden conservatory followed by matcha.",
                isCurrentUser: false
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
