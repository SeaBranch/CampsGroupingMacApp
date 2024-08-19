import SwiftUI

struct CampsDetailView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>
    @State private var reportID: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let camp = coordinator.state.camp {
                if let campSettings = camp.campSettings {
                    Button("Configure Report Fields") {
                        coordinator.send(event: .camp(event: .didSelectManageReport(camp: camp)))
                    }
                    ForEach(
                        campSettings.withChanges(camp.changes).report.reportFieldSettings,
                        id: \.fieldName
                    ) { field in
                        HStack {
                            Text(field.fieldName + ":")
                            Spacer()
                            Text(field.fieldType.displayName)
                        }
                    }

                    if campSettings.hasMinimumRequiredSettings {
                        viewGroupingSection(camp: camp)
                    }
                }

                setReportIdSection()
            }
        }
    }

    @ViewBuilder
    func viewGroupingSection(camp: Camp) -> some View {
        Button(
            "View Camper Grouping"
        ) {
            coordinator.send(event: .camp(event: .didSelectViewGrouping(camp: camp)))
        }
        .disabled(reportID.isEmpty)
    }

    @ViewBuilder
    func setReportIdSection() -> some View {
        TextField("Report ID", text: $reportID)
        let idOnFile = coordinator.state.camp?.campSettings?.report.reportID ?? ""
        Button(
            idOnFile.isEmpty
            ? "Set Report ID"
            : "Change Report ID"
        ) {
            // TODO: send report ID
        }.disabled(reportID.isEmpty)
    }
}
