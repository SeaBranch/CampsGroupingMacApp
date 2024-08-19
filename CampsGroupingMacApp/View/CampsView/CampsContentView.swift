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
