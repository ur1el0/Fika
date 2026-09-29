//
//  DiscoverViewModel.swift
//  Common Ground
//
//  Manages the discover feed, Tinder/Bumble card deck swipe states, undo history, and match celebration
//

import SwiftUI
import SwiftData
import Observation

enum SwipeActionType {
    case pass
    case like
    case superLike
}

struct SwipeRecord {
    let profile: DatingProfile
    let actionType: SwipeActionType
    let createdConnectionId: UUID?
}

@Observable
@MainActor
final class DiscoverViewModel {
    var selectedInterestFilter: String? = nil
    var searchText: String = ""
    var currentIndex: Int = 0
    var feedbackMessage: String? = nil
    var errorMessage: String? = nil
    var selectedProfileForDetail: DatingProfile? = nil
    
    // Modern dating app features
    var matchedProfile: DatingProfile? = nil
    var isFilterSheetPresented: Bool = false
    var swipeHistory: [SwipeRecord] = []
    
    var canUndo: Bool {
        currentIndex > 0 && !swipeHistory.isEmpty
    }
    
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
    
    func connect(
        profile: DatingProfile,
        currentUser: DatingProfile?,
        existingConnections: [Connection],
        context: ModelContext
    ) {
        feedbackMessage = nil
        errorMessage = nil
        
        // Check if already connected
        if let existing = existingConnections.first(where: { $0.profile?.id == profile.id }) {
            feedbackMessage = "\(profile.displayName) is already saved in your Connections."
            swipeHistory.append(SwipeRecord(profile: profile, actionType: .like, createdConnectionId: existing.id))
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
            swipeHistory.append(SwipeRecord(profile: profile, actionType: .like, createdConnectionId: newConnection.id))
            
            // Trigger Tinder/Bumble match celebration if mutual connection or shared passions exist
            let shared = profile.sharedInterests(with: currentUser)
            if !shared.isEmpty {
                matchedProfile = profile
            } else {
                feedbackMessage = "Connected with \(profile.displayName)!"
            }
            
            advanceCard()
        } catch {
            errorMessage = "Could not save connection: \(error.localizedDescription)"
        }
    }
    
    func superLike(
        profile: DatingProfile,
        currentUser: DatingProfile?,
        existingConnections: [Connection],
        context: ModelContext
    ) {
        feedbackMessage = nil
        errorMessage = nil
        
        // Check if already connected
        if let existing = existingConnections.first(where: { $0.profile?.id == profile.id }) {
            existing.typedStatus = .mutualSpark
            do {
                try context.save()
                swipeHistory.append(SwipeRecord(profile: profile, actionType: .superLike, createdConnectionId: existing.id))
                matchedProfile = profile
                advanceCard()
            } catch {
                errorMessage = "Failed to update connection: \(error.localizedDescription)"
            }
            return
        }
        
        let newConnection = Connection(
            status: ConnectionStatus.mutualSpark.rawValue,
            createdAt: Date(),
            profile: profile
        )
        context.insert(newConnection)
        
        do {
            try context.save()
            swipeHistory.append(SwipeRecord(profile: profile, actionType: .superLike, createdConnectionId: newConnection.id))
            matchedProfile = profile
            advanceCard()
        } catch {
            errorMessage = "Could not save super like: \(error.localizedDescription)"
        }
    }
    
    func pass(profile: DatingProfile) {
        feedbackMessage = nil
        errorMessage = nil
        swipeHistory.append(SwipeRecord(profile: profile, actionType: .pass, createdConnectionId: nil))
        advanceCard()
    }
    
    func undoLastSwipe(context: ModelContext) {
        guard canUndo, let lastRecord = swipeHistory.popLast() else { return }
        
        // If this record created a connection, remove it
        if let connId = lastRecord.createdConnectionId {
            do {
                let descriptor = FetchDescriptor<Connection>(
                    predicate: #Predicate<Connection> { $0.id == connId }
                )
                if let connToDelete = try context.fetch(descriptor).first {
                    context.delete(connToDelete)
                    try context.save()
                }
            } catch {
                print("Failed to delete undone connection: \(error.localizedDescription)")
            }
        }
        
        currentIndex = max(0, currentIndex - 1)
        feedbackMessage = "Restored \(lastRecord.profile.displayName)"
    }
    
    func advanceCard() {
        currentIndex += 1
    }
    
    func resetIndex() {
        currentIndex = 0
        swipeHistory.removeAll()
        feedbackMessage = nil
        errorMessage = nil
    }
}
