//
//  ContentView.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 3/21/24.
//

import Combine
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]

    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        if coordinator.state.isAuthenticated {
            splitNav()
        } else {
            SignInView()
        }
    }

    @ViewBuilder
    func splitNav() -> some View {
        NavigationSplitView {
            List {
                ForEach(coordinator.state.accounts) { account in
                    NavigationLink {
                        Text(account.scope.rawValue)
                    } label: {
                        Text(account.scope.rawValue)
                    }
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
            }
        } detail: {
            Text(Strings.selectACampsCategory)
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(
            EventCoordinator<GrouperEventSpace>(state: .init())
        )
        .environmentObject(
            SignInViewModel(
                state: .init(),
                statePublisher: Just(GrouperEventSpace.State()).eraseToAnyPublisher(),
                onEvent: { _ in }
            )
        )
}
