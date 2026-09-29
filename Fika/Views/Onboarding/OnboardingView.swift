//
//  OnboardingView.swift
//  Common Ground
//
//  First-launch onboarding screen for creating the current user's profile
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    
    var onCompleted: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    headerSection
                    
                    if let error = viewModel.validationError {
                        errorBanner(message: error)
                    }
                    if let saveError = viewModel.saveError {
                        errorBanner(message: saveError)
                    }
                    
                    basicInfoSection
                    intentAndBioSection
                    interestsSection
                    firstDateSection
                    prototypeNoticeSection
                    
                    Button {
                        if viewModel.createProfile(context: modelContext) {
                            onCompleted()
                        }
                    } label: {
                        Text("Create Profile & Begin")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, Theme.Spacing.md)
                    
                    Button {
                        viewModel.displayName = "Elena Rostova"
                        viewModel.age = 26
                        viewModel.city = "Portland, OR"
                        viewModel.bio = "Ceramics artist and avid collector of vintage botanical prints. Looking for calm coffee chats and thoughtful weekend market walks."
                        viewModel.relationshipIntent = "Intentional dating"
                        viewModel.selectedInterests = ["Specialty Coffee", "Indie Bookstores", "Pottery & Ceramics", "Botanical Gardens"]
                        viewModel.preferredFirstDateActivity = "Pour-over coffee and antiquarian bookstore browse"
                    } label: {
                        Text("Fill Sample User (Demo Shortcut)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Theme.Colors.accentCoral)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, Theme.Spacing.xs)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.xl)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("COMMON GROUND")
                .font(.caption.weight(.bold))
                .tracking(2.0)
                .foregroundColor(Theme.Colors.accentCoral)
            
            Text("Begin with intention.")
                .font(.largeTitle.weight(.semibold))
                .fontDesign(.serif)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text("An intentional space for adults aged 18+ to connect through shared passions, values, and preferred first dates.")
                .font(.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)
                .lineSpacing(3)
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(title: "The Basics", subtitle: "Tell others who you are and where you are based.")
            
            VStack(spacing: Theme.Spacing.sm) {
                inputField(title: "Display Name", placeholder: "e.g. Maya", text: $viewModel.displayName)
                
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
                
                inputField(title: "City / Neighborhood", placeholder: "e.g. Seattle, WA", text: $viewModel.city)
            }
        }
    }
    
    private var intentAndBioSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(title: "Intent & Story", subtitle: "Be honest about what you are seeking.")
            
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
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Bio & Outlook")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.Colors.secondaryText)
                
                TextField(
                    "Share your passions, daily rituals, and what brings you joy...",
                    text: $viewModel.bio,
                    axis: .vertical
                )
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
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(title: "Interests & Pursuits", subtitle: "Select activities you enjoy to help find common ground.")
            
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
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(title: "Ideal First Date", subtitle: "Skip the awkward small talk with an intentional first date idea.")
            
            inputField(
                title: "Preferred Activity",
                placeholder: "e.g. Pour-over tasting & bookstore stroll",
                text: $viewModel.preferredFirstDateActivity
            )
        }
    }
    
    private var prototypeNoticeSection: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: "info.circle")
                .foregroundColor(Theme.Colors.secondaryText)
                .font(.subheadline)
            Text("School Project Demo: Common Ground runs locally on device using SwiftData. No accounts, remote servers, or actual messaging exist.")
                .font(.caption)
                .foregroundColor(Theme.Colors.secondaryText)
                .lineSpacing(2)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(title)
                .font(.headline)
                .fontDesign(.serif)
                .foregroundColor(Theme.Colors.primaryText)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(Theme.Colors.secondaryText)
        }
    }
    
    private func inputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(Theme.Colors.secondaryText)
            TextField(placeholder, text: text)
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
    
    private func errorBanner(message: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.red)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}
