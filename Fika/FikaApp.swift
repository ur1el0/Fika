//
//  FikaApp.swift
//  Common Ground
//
//  Application entry point and SwiftData ModelContainer configuration
//

import SwiftUI
import SwiftData

@main
struct FikaApp: App {
    let container: ModelContainer
    
    init() {
        let schema = Schema([
            DatingProfile.self,
            Connection.self,
            DatePlan.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer for Common Ground: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
