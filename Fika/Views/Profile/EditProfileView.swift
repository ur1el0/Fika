//
//  EditProfileView.swift
//  Common Ground
//
//  Form for editing the current user's profile with validation and persistence
//

import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var profile: DatingProfile
    
    @State private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    if let err = viewModel.validationError {
                        banner(message: err, isError: true)
                    }
                    if let err = viewModel.errorMessage {
                        banner(message: err, isError: true)
                    }
                    
                    // Basics
                    basicsSection
                    
                    // Intent & Bio
                    intentAndBioSection
                    
                    // Interests
                    interestsSection
                    
                    // First Date
                    firstDateSection
                    
                    // Save Button
                    Button {
                        if viewModel.updateProfile(profile: profile, context: modelContext) {
                            dismiss()
                        }
                    } label: {
                        Text("Save Profile Changes")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, Theme.Spacing.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            .onAppear {
                viewModel.load(profile: profile)
            }
        }
    }
    
    // MARK: - Sections
    
    private var basicsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("BASIC INFORMATION")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Display Name")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("Your Name", text: $viewModel.displayName)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
            
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("Age (18+ required)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text("\(viewModel.age) years old")
                        .font(.body.weight(.medium))
                        .foregroundColor(Theme.Colors.primaryText)
                }
                Spacer()
                Stepper("", value: $viewModel.age, in: 18...100)
                    .labelsHidden()
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("City / Neighborhood")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("e.g. Seattle, WA", text: $viewModel.city)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var intentAndBioSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("INTENT & STORY")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Relationship Intention")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.secondaryText)
                
                FlowLayout(spacing: Theme.Spacing.xs) {
                    ForEach(DataSeeder.relationshipIntentions, id: \.self) { intent in
                        InterestTagPill(
                            title: intent,
                            isSelected: viewModel.relationshipIntent == intent,
                            action: {
                                viewModel.relationshipIntent = intent
                            }
                        )
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Bio & Philosophy")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("Share your story...", text: $viewModel.bio, axis: .vertical)
                    .lineLimit(3...5)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("INTERESTS")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: Theme.Spacing.sm)], spacing: Theme.Spacing.sm) {
                ForEach(DataSeeder.availableInterests, id: \.self) { interest in
                    let isSelected = viewModel.selectedInterests.contains(interest)
                    InterestTagPill(
                        title: interest,
                        isSelected: isSelected,
                        action: {
                            viewModel.toggleInterest(interest)
                        }
                    )
                }
            }
        }
    }
    
    private var firstDateSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("FIRST DATE PREFERENCE")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundColor(Theme.Colors.secondaryText)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Preferred Activity")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.secondaryText)
                TextField("e.g. Pour-over tasting & bookstore stroll", text: $viewModel.preferredFirstDateActivity)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private func banner(message: String, isError: Bool) -> some View {
        HStack {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : Theme.Colors.sage)
            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundColor(isError ? .red : Theme.Colors.primaryText)
        }
        .padding(Theme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isError ? Color.red.opacity(0.1) : Theme.Colors.sage.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
    }
}
