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
        } else {
            VStack(spacing: 2) {
                Text("Auto Group")
                ForEach(coordinator.state.camp?.groupingFields ?? [], id: \.self) { fieldName in
                    HStack {
                        Text(fieldName + ":")
                        Spacer()
                        TextField("equivelence", text: Binding<String>(get: {
                            "\(coordinator.state.camp?.equivelencies[fieldName] ?? 0)"
                        }, set: { newValue in
                            if let value = Double(newValue) {
                                coordinator.send(
                                    event: .grouping(
                                        event: .setEquivelence(
                                            equivelence: value,
                                            fieldName: fieldName
                                        )
                                    )
                                )
                            }
                        }))
                    }
                }

                Button("Auto Group") {
                    coordinator.send(event: .grouping(event: .didTapAutoGroupRemainingCampers))
                }

                Button("Confirm Auto Grouping") {
                    coordinator.send(event: .grouping(event: .didTapAcceptAutoGrouping))
                }
                .disabled(coordinator.state.groupingState?.pendingAssignments.isEmpty ?? true)

                Button("Commit Group Assignments") {
                    coordinator.send(event: .grouping(event: .requestUploadGroupAssignments))
                }
                .disabled(!(coordinator.state.camp?.campSettings?.campers.map { $0.status }.contains(.edited) ?? false))

                VSeparator(color: .primary)
                ForEach(coordinator.state.groupingState?.pendingAssignments ?? [], id: \.camper.id) { assignment in
                    Text("\(assignment.camper.name) -> \(assignment.group.groupNumber)")
                }
                VSeparator(color: .primary)
            }
        }
    }
}
