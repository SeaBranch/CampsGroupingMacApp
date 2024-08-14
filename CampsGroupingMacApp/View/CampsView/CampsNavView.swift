import SwiftUI

struct CampsNavView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        NavigationStack {
            if !coordinator.state.camps.isEmpty, let scope = coordinator.state.campScope {
                List {
                    ForEach(coordinator.state.camps, id: \.info.eventNumber) { camp in
                        CampMenuRow(scope: scope, camp: camp)
                    }
                }
            } else {
                Text("No camps found in \(coordinator.state.campScope.map { "\($0.rawValue)" } ?? "NO SCOPE SELECTED")")
            }
        }.toolbar {
            HStack {
                Button("Sign Out") {
                    coordinator.send(event: .menu(event: .didSignOut))
                }
            }
        }
    }
}

struct CampMenuRow: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>
    let scope: CampsScope
    let camp: Camp

    var body: some View {
        Button {
            coordinator.send(event: .menu(event: .didSelectCamp(camp: camp, scope: scope)))
        } label: {
            VStack {
                Text(camp.info.title).font(.title)
                HStack {
                    Text("\(camp.info.eventNumber)").font(.footnote)
                    Spacer()
                    Text(camp.info.dateInfo)
                }
            }
        }
    }
}
