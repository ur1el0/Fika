//
//  ContentView.swift
//  Common Ground
//
//  Main container view with tab navigation and onboarding coordinator
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Live query to determine if current user profile exists
    @Query(filter: #Predicate<DatingProfile> { $0.isCurrentUser })
    private var currentUserList: [DatingProfile]
    
    @State private var selectedTab: Int = ContentView.initialTab
    @State private var isOnboardingPresented: Bool = false
    
    private static var initialTab: Int {
        if let idx = CommandLine.arguments.firstIndex(of: "-tab"),
           idx + 1 < CommandLine.arguments.count,
           let val = Int(CommandLine.arguments[idx + 1]) {
            return val
        }
        return 0
    }
    
    var body: some View {
        Group {
            if currentUserList.isEmpty {
                // First-launch onboarding flow
                OnboardingView(onCompleted: {
                    isOnboardingPresented = false
                })
            } else {
                // Main Tab Navigation
                TabView(selection: $selectedTab) {
                    DiscoverView()
                        .tabItem {
                            Label("Discover", systemImage: "sparkles")
                        }
                        .tag(0)
                    
                    ConnectionsListView()
                        .tabItem {
                            Label("Connections", systemImage: "bookmark.fill")
                        }
                        .tag(1)
                    
                    DatePlansListView()
                        .tabItem {
                            Label("Date Plans", systemImage: "calendar")
                        }
                        .tag(2)
                    
                    MyProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(3)
                }
                .tint(Theme.Colors.accentCoral)
            }
        }
        .onAppear {
            if CommandLine.arguments.contains("-verifyCRUD") {
                _ = CRUDVerifier.runVerification(context: modelContext)
            }
            // Seed fictional demo profiles on first launch
            DataSeeder.seedIfNeeded(context: modelContext)
        }
    }
}
