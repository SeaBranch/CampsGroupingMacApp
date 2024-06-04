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
    var coordinator: EventCoordinator<GrouperEventSpace> {
        EventCoordinator<GrouperEventSpace>(
            state: GrouperEventSpace.State(),
            actionHandlers: [
                SignInActionHandler()
            ]
        )
    }

//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        let coordinator = self.coordinator

        WindowGroup {
            ContentView()
        }
//        .modelContainer(sharedModelContainer)
        .environmentObject(coordinator)
        .environmentObject(SignInViewModel(coordinator: coordinator))
    }
}
