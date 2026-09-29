//
//  OnboardingViewModel.swift
//  Common Ground
//
//  Manages the first-launch profile creation flow with validation and persistence
//

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    var displayName: String = ""
    var age: Int = 24
    var city: String = ""
    var bio: String = ""
    var relationshipIntent: String = "Intentional dating"
    var selectedInterests: Set<String> = []
    var preferredFirstDateActivity: String = ""
    
    var validationError: String? = nil
    var saveError: String? = nil
    
    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
    
    func createProfile(context: ModelContext) -> Bool {
        validationError = nil
        saveError = nil
        
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
        
        let profile = DatingProfile(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            age: age,
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
            relationshipIntent: relationshipIntent,
            interests: interestsArray,
            preferredFirstDateActivity: preferredFirstDateActivity.trimmingCharacters(in: .whitespacesAndNewlines),
            isCurrentUser: true
        )
        
        context.insert(profile)
        
        do {
            try context.save()
            return true
        } catch {
            saveError = "Failed to save profile: \(error.localizedDescription)"
            return false
        }
    }
}
