//
//  CampsGroupingMacAppApp.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 3/21/24.
//

import SwiftUI
import SwiftData

@main
struct CampsGroupingMacAppApp: App {
    func coordinator(withModel container: ModelContainer) -> EventCoordinator<GrouperEventSpace> {
        EventCoordinator<GrouperEventSpace>(
            state: GrouperEventSpace.State(),
            actionHandlers: [
                NetworkActionHandler(modelContainer: container)
            ]
        )
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppLogin.self,
            CampsStateMemory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        let modelContainer = sharedModelContainer
        let coordinator = self.coordinator(withModel: modelContainer)

        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(coordinator)
        .environmentObject(SignInViewModel(coordinator: coordinator))
    }
}
