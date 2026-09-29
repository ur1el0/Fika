//
//  DatingProfile.swift
//  Common Ground
//
//  Created for SwiftData Persistence Demonstration
//

import Foundation
import SwiftData

@Model
final class DatingProfile {
    var id: UUID = UUID()
    var displayName: String = ""
    var age: Int = 18
    var city: String = ""
    var bio: String = ""
    var relationshipIntent: String = ""
    var interests: [String] = []
    var preferredFirstDateActivity: String = ""
    var isCurrentUser: Bool = false
    var createdAt: Date = Date()
    
    
    // Explicit inverse cascade delete rule: deleting a profile cascades to its connections
    @Relationship(deleteRule: .cascade, inverse: \Connection.profile)
    var connections: [Connection]? = []
    
    init(
        id: UUID = UUID(),
        displayName: String,
        age: Int,
        city: String,
        bio: String,
        relationshipIntent: String,
        interests: [String],
        preferredFirstDateActivity: String,
        isCurrentUser: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.age = age
        self.city = city
        self.bio = bio
        self.relationshipIntent = relationshipIntent
        self.interests = interests
        self.preferredFirstDateActivity = preferredFirstDateActivity
        self.isCurrentUser = isCurrentUser
        self.createdAt = createdAt
        self.connections = []
    }
    
    // MARK: - Common Ground Computation
    
    /// Returns the subset of interests shared with the given user profile.
    func sharedInterests(with user: DatingProfile?) -> [String] {
        guard let user else { return [] }
        let userSet = Set(user.interests.map { $0.lowercased() })
        return self.interests.filter { userSet.contains($0.lowercased()) }
    }
    
    /// Synthesizes a human-readable prompt explaining why the two profiles share common ground.
    func commonGroundReason(with user: DatingProfile?) -> String {
        guard let user else {
            return "Curious about your world: Open to thoughtful conversations."
        }
        
        let shared = sharedInterests(with: user)
        if !shared.isEmpty {
            if shared.count == 1 {
                return "Shared Passion: You both appreciate \(shared[0])."
            } else {
                let firstTwo = shared.prefix(2).joined(separator: " & ")
                return "Common Ground: Mutual love for \(firstTwo)."
            }
        }
        
        if self.relationshipIntent.caseInsensitiveCompare(user.relationshipIntent) == .orderedSame {
            return "Aligned Intent: Both seeking \(self.relationshipIntent.lowercased())."
        }
        
        if self.city.caseInsensitiveCompare(user.city) == .orderedSame {
            return "Neighborhood Kinship: Both based in \(self.city)."
        }
        
        return "Complementary Vibes: You both value calm, intentional beginnings."
    }
    
    // MARK: - Validation
    
    static func validate(
        displayName: String,
        age: Int,
        city: String,
        bio: String,
        relationshipIntent: String,
        interests: [String],
        preferredFirstDateActivity: String
    ) -> String? {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return "Please provide your display name."
        }
        if trimmedName.count < 2 {
            return "Display name must be at least 2 characters."
        }
        if age < 18 {
            return "You must be 18 years or older to use Common Ground."
        }
        if age > 120 {
            return "Please enter a valid age."
        }
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedCity.isEmpty {
            return "Please specify your city or neighborhood."
        }
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedBio.isEmpty {
            return "Please write a brief bio about yourself."
        }
        if trimmedBio.count < 10 {
            return "Bio should be at least 10 characters so others can get to know you."
        }
        let trimmedIntent = relationshipIntent.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedIntent.isEmpty {
            return "Please select or enter your relationship intention."
        }
        if interests.isEmpty {
            return "Please select at least one interest."
        }
        let trimmedActivity = preferredFirstDateActivity.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedActivity.isEmpty {
            return "Please describe your preferred first date activity."
        }
        return nil
    }
}
