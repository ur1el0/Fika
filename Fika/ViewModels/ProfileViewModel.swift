//
//  ProfileViewModel.swift
//  Common Ground
//
//  Manages viewing and updating the current user's profile and demo data utilities
//

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var displayName: String = ""
    var age: Int = 24
    var city: String = ""
    var bio: String = ""
    var relationshipIntent: String = ""
    var selectedInterests: Set<String> = []
    var preferredFirstDateActivity: String = ""
    
    var isPresentingEditSheet: Bool = false
    var isShowingResetAlert: Bool = false
    
    var validationError: String? = nil
    var errorMessage: String? = nil
    var successMessage: String? = nil
    
    func load(profile: DatingProfile) {
        displayName = profile.displayName
        age = profile.age
        city = profile.city
        bio = profile.bio
        relationshipIntent = profile.relationshipIntent
        selectedInterests = Set(profile.interests)
        preferredFirstDateActivity = profile.preferredFirstDateActivity
        validationError = nil
        errorMessage = nil
    }
    
    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
    
    func updateProfile(profile: DatingProfile, context: ModelContext) -> Bool {
        validationError = nil
        errorMessage = nil
        
        let interestsArray = Array(selectedInterests)
        if let error = DatingProfile.validate(
            displayName: displayName,
            age: age,
            city: city,
            bio: bio,
            relationshipIntent: relationshipIntent,
            interests: interestsArray,
            preferredFirstDateActivity: preferredFirstDateActivity
        ) {
            validationError = error
            return false
        }
        
        profile.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.age = age
        profile.city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.relationshipIntent = relationshipIntent
        profile.interests = interestsArray
        profile.preferredFirstDateActivity = preferredFirstDateActivity.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try context.save()
            successMessage = "Profile updated successfully!"
            isPresentingEditSheet = false
            return true
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            return false
        }
    }
    
    func resetDemoData(context: ModelContext) {
        DataSeeder.resetToInitialSeed(context: context)
        successMessage = "Demo profiles and connections reset to initial state."
    }
}
