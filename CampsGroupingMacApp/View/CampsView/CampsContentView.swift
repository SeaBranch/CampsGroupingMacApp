import SwiftUI

struct CampsContentView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        if let camp = coordinator.state.camp, let scope = coordinator.state.campScope {
            campBasicDetails(camp: camp, scope: scope)
        } else {
            Text("Select a Camp")
        }
    }

    @ViewBuilder
    func campBasicDetails(camp: Camp, scope: CampsScope) -> some View {
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            heading(campInfo: camp.info)
            subheading(campInfo: camp.info)
            whereAndWhen(campInfo: camp.info)
            Spacer()

            if coordinator.state.isPerformingSetReportCall {
                ProgressView {
                    Text("setting report id")
                }
            }

            if coordinator.state.isPerformingCampReportCall {
                ProgressView {
                    Text("getting report")
                }
            } else if let errorInfo = coordinator.state.campReportErrorInfo {
                VStack {
                    Text("Error: \(errorInfo.error.status)")
                        Text("Could not get camp report")
                    Button("Retry") {
                        coordinator.send(event: .api(event: .retryNetworkCall(errorInfo.networkCall)))
                    }
                }
            }

            if coordinator.state.isPerformingCamperSettingsCall {
                ProgressView {
                    Text("getting camper assignments")
                }
            } else if let errorInfo = coordinator.state.camperSettingsErrorInfo {
                VStack {
                    Text("Error: \(errorInfo.error.status)")
                        Text("Could not get camper settings")
                    Button("Retry") {
                        coordinator.send(event: .api(event: .retryNetworkCall(errorInfo.networkCall)))
                    }
                }
            }

            if coordinator.state.isPerformingCampReportFormatCall {
                ProgressView {
                    Text("getting camp report format")
                }
            } else if let errorInfo = coordinator.state.campReportFormatErrorInfo {
                VStack {
                    Text("Error: \(errorInfo.error.status)")
                        Text("Could not get camp report format")
                    Button("Retry") {
                        coordinator.send(event: .api(event: .retryNetworkCall(errorInfo.networkCall)))
                    }
                }
            }

            CampGroupDetailsView(camp: camp)

            Spacer()
            footer(campInfo: camp.info)
        }
    }

    @ViewBuilder
    func heading(campInfo: CampInfo) -> some View {
        HStack {
            Text(campInfo.title).font(.title)
            Spacer()
            Text("Event ID:" + "\(campInfo.eventNumber)").font(.body)
        }
    }

    @ViewBuilder
    func subheading(campInfo: CampInfo) -> some View {
        let subtitle = subtitle(for: campInfo)
        if !subtitle.isEmpty {
            HStack {
                Text(subtitle).font(.footnote)
            }
        }
    }

    func subtitle(for campInfo: CampInfo) -> String {
        var subtitle = campInfo.subtitle
        if !subtitle.isEmpty {
            subtitle += " "
        }

        if let alternateTitle = campInfo.alternateTitle,
           alternateTitle != campInfo.title {
            subtitle += "(aka \"\(alternateTitle)\")"
        }

        return subtitle
    }

    @ViewBuilder
    func whereAndWhen(campInfo: CampInfo) -> some View {
        Text("\(campInfo.dateInfo) @ \(campInfo.locationName)")
    }

    @ViewBuilder
    func footer(campInfo: CampInfo) -> some View {
        if campInfo.isActive {
            Text("Active").foregroundColor(.green)
        }
    }
}

struct CampGroupDetailsView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State var camp: Camp
    @State var filterForCaptains = false

    var body: some View {
        if camp.groups.isEmpty && coordinator.state.activeFetches.contains(where: { call in
            if case .groups(let uUID) = call {
                true
            } else {
                false
            }
        }) {
            ProgressView {
                Text("Loading Groups...").font(.largeTitle)
            }
        } else {
            VStack {
                VSeparator(color: .primary)
                HStack {
                    Text("Groups in \(camp.info.title)").font(.largeTitle)
                    Spacer()
                }.padding()

                HStack {
                    Toggle("View only groups with leaders", isOn: $filterForCaptains)
                    Spacer()
                }.padding()
                VSeparator(color: .secondary)
                ScrollView {
                    VStack {
                        ForEach(filteredGroups, id: \.groupID) { group in
                            groupPannel(group: group).padding()
                        }
                    }.padding()
                }
            }
        }
    }

    var filteredGroups: [CampGroup] {
        if filterForCaptains {
            camp.groups.filter { $0.type == .tripCaptain }
        } else {
            camp.groups
        }
    }

    @ViewBuilder func groupPannel(group: CampGroup) -> some View {
        VStack {
            Text(group.groupName + ": " + "\(group.groupID)").font(.title)
            Text("number of campers: " + "\(group.attendeeCount)")
            Spacer().frame(height: 8)
            Text("Campers:")
            VSeparator(color: .secondary)
            ForEach(group.campers, id: \.id) { camper in
                HStack {
                    Text(camper.name)
                    Spacer()
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 8).fill(Color(enum: .plain))
        }
    }

    func campers(forIDs camperIDs: [Int]) -> [Camper] {
        camp.campers.filter { camper in
            camperIDs.contains(camper.id)
        }
    }
}

struct VSeparator: View {
    @State var color: Color

    var body: some View {
        Rectangle().fill(color).frame(height: 1)
    }
}

struct HSeparator: View {
    @State var color: Color

    var body: some View {
        Rectangle().fill(color).frame(width: 1)
    }
}
