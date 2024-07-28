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
        splitNav(navMode: coordinator.state.navigationMode)
    }

    @ViewBuilder
    fileprivate func campView(for camp: Camp, andScope scope: CampsScope) -> some View {
        VStack {
            Text(camp.title)
            if let reportID = camp.reportID {
                Button("Manage Report") {
                    coordinator.send(event: .camp(event: .didSelectManageReport(camp: camp, scope: scope)))
                }
            } else {
                Text("No Report Found")
            }
        }
    }
    
    @ViewBuilder
    func campsSplitNav(scope: CampsScope) -> some View {
        NavigationSplitView {
            List {
                ForEach(coordinator.state.camps) { camp in
                    NavigationLink {
                        campView(for: camp, andScope: scope)
                    } label: {
                        Text(camp.title)
                    }
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {

                    ToolbarItem(placement: .navigation) {
                        Button("Sign Out") {
                            coordinator.send(event: .menu(event: .didSignOut))
                        }
                    }

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

    @ViewBuilder
    func splitNav(navMode: NavigationMode) -> some View {
        switch navMode {
        case .signin:
            SignInView()
        case .camps(let scope):
            campsSelectionView(scope: scope)
        case .report:
            ReportView()
        case .grouping:
            Text("Grouping")
        }
    }

    @ViewBuilder
    func campsSelectionView(scope: CampsScope) -> some View {
        if coordinator.state.campsResult == nil {
            ProgressView()
        } else {
            campsSplitNav(scope: scope)
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
