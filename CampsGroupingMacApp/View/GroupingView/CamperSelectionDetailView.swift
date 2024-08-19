import SwiftUI

struct CamperSelectionDetailView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State var showDetails = true

    var body: some View {

        if let camperID = coordinator.state.groupingState?.camperCurrentlyBeingGrouped,
           let camper = coordinator.state.camp?.campers.first(where: { $0.id == camperID }) {
            VStack(spacing: 2) {
                HStack {
                    Text(camper.name)
                    Spacer()
                }

                let groupingFields = coordinator.state.currentFields
                    .filter {
                        ($0.includeInGrouping || $0.showInTable)
                        && !($0.isRegistrantData && $0.fieldType == .fullName)
                    }
                    .map { $0.fieldName }

                let values = camper.values
                    .filter {
                        groupingFields.contains($0.key) &&
                        !$0.value.rawValue.isEmpty
                    }
                    .sorted(by: { e1, e2 in
                        e1.key < e2.key
                    })
                    .map { ($0.key, $0.value) }
                Rectangle().fill(.primary).frame(height: 1)
                if showDetails {
                    ForEach(values, id: \.0) { groupingValue in
                        HStack {
                            Text(
                                "\(groupingValue.0):\n\t\(groupingValue.1.rawValue)"
                            )
                            .font(.footnote)
                            Spacer()
                        }
                    }
                }

                Button(showDetails ? "hide details" : "show details") {
                    showDetails.toggle()
                }
            }
            .padding()
        }
    }
}
