//
//  DiscoverViewModel.swift
//  Common Ground
//
//  Manages the discover feed, interest filtering, and Connect/Pass interactions
//

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
final class DiscoverViewModel {
    var selectedInterestFilter: String? = nil
    var searchText: String = ""
    var currentIndex: Int = 0
    var feedbackMessage: String? = nil
    var errorMessage: String? = nil
    var selectedProfileForDetail: DatingProfile? = nil
    
    func filterProfiles(_ profiles: [DatingProfile]) -> [DatingProfile] {
        profiles.filter { profile in
            // Exclude current user
            guard !profile.isCurrentUser else { return false }
            
            // Filter by interest tag if selected
            if let filter = selectedInterestFilter, !filter.isEmpty {
                let matchesInterest = profile.interests.contains { $0.caseInsensitiveCompare(filter) == .orderedSame }
                if !matchesInterest { return false }
            }
            
            // Filter by search text
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let query = searchText.lowercased()
                let nameMatches = profile.displayName.lowercased().contains(query)
                let cityMatches = profile.city.lowercased().contains(query)
                let bioMatches = profile.bio.lowercased().contains(query)
                let interestMatches = profile.interests.contains { $0.lowercased().contains(query) }
                if !(nameMatches || cityMatches || bioMatches || interestMatches) {
                    return false
                }
            }
            
            return true
        }
    }
    
    func connect(profile: DatingProfile, existingConnections: [Connection], context: ModelContext) {
        feedbackMessage = nil
        errorMessage = nil
        
        // Check if already connected
        if let existing = existingConnections.first(where: { $0.profile?.id == profile.id }) {
            feedbackMessage = "\(profile.displayName) is already saved in your Connections."
            advanceCard()
            return
        }
        
        let newConnection = Connection(
            status: ConnectionStatus.saved.rawValue,
            createdAt: Date(),
            profile: profile
        )
        context.insert(newConnection)
        
        do {
            try context.save()
            feedbackMessage = "Saved connection with \(profile.displayName)!"
            advanceCard()
        } catch {
            errorMessage = "Could not save connection: \(error.localizedDescription)"
        }
    }
    
    func pass(profile: DatingProfile) {
        advanceCard()
    }
    
    func advanceCard() {
        currentIndex += 1
    }
    
    func resetIndex() {
        currentIndex = 0
    }
}
