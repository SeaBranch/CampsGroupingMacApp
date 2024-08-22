import SwiftUI
import ApplicationServices

struct CamperAndGroupSearchView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State private var searchQuery = ""

    var columns: [GridItem] {
        let groupingFields = coordinator.state.currentFields
            .filter { $0.showInTable }

        var columns: [GridItem] = []

        for field in groupingFields {
            columns.append(GridItem(.flexible(minimum: 0, maximum: .infinity)))
        }

        return columns
    }

    var body: some View {
        HStack {
            VStack {
                let groupingFields = coordinator.state.currentFields
                    .filter { $0.showInTable }
                TextField("Search", text: $searchQuery)
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(groupingFields, id: \.fieldName) { field in
                        Button {
                            coordinator.send(event: .grouping(event: .didSelectField(field: field)))
                        } label: {
                            HStack {
                                Text(field.fieldName)
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(
                            coordinator.state.groupingState?.activeSelection?.field.fieldName == field.fieldName
                            ? Color(enum: .select)
                            : Color(enum: .plain)
                        )
                    }
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        prioritizedCampers(fields: groupingFields, selection: coordinator.state.groupingState?.activeSelection)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    func prioritizedCampers(fields: [ReportFieldSetting], selection: CamperGroupingFocus? = nil) -> some View {
        let campers = filteredAndSortedCampers(selection: selection)

        ForEach(
            [CamperRowDataElement]
                .fromCampers(
                    campers,
                    selectedCamper: coordinator.state.selectedCamper,
                    andFields: fields
                )
        ) { camperRow in
            camperView(camperRow)
        }
    }

    private func filteredAndSortedCampers(selection: CamperGroupingFocus?) -> [Camper] {
        let campers = coordinator.state.camp?.campers ?? []
        var filteredArray = campers.filteredBySearch(
            query: searchQuery,
            exclude: coordinator.state.groupingState?.camperCurrentlyBeingGrouped
        )

        if let focus = selection {
            filteredArray = filteredArray.filteredByFiltered(focus.filter)
            filteredArray = filteredArray.sorted { c1, c2 in
                var c1Value = c1.values[focus.field.fieldName]
                var c2Value = c2.values[focus.field.fieldName]

                var c1Val = c1.values[focus.field.fieldName]?.rawValue
                var c2Val = c2.values[focus.field.fieldName]?.rawValue

                if focus.field.fieldType == .groupNumber {
                    let camper1Pending = coordinator.state.groupingState?.pendingAssignments.first { $0.camper.id == c1.id }
                    let camper2Pending = coordinator.state.groupingState?.pendingAssignments.first { $0.camper.id == c2.id }
                    let cid1 = camper1Pending?.group.groupNumber ?? c1.currentGroup?.groupNumber
                    let cid2 = camper2Pending?.group.groupNumber ?? c2.currentGroup?.groupNumber

                    switch focus.sortOrder {
                    case .forward:
                        return (cid1 ?? .max) < (cid2 ?? .max)
                    case .reverse:
                        return (cid1 ?? 0) > (cid2 ?? 0)
                    }
                }

                switch focus.sortOrder {
                case .forward:
                    var val1 = c1.values[focus.field.fieldName]?.rawValue
                    ?? "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
                    if val1.isEmpty {
                        val1 = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
                    }
                    var val2 = c2.values[focus.field.fieldName]?.rawValue
                    ?? "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
                    if val2.isEmpty {
                        val2 = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
                    }

                    return val1 < val2
                case .reverse:
                    return c1.values[focus.field.fieldName]?.rawValue ?? ""
                    > c2.values[focus.field.fieldName]?.rawValue ?? ""
                }
            }
        }

        return filteredArray
    }

    @ViewBuilder
    func camperView(_ camperElement: CamperRowDataElement) -> some View {
        let isSelected = coordinator.state.groupingState?.camperSelections
            .contains(camperElement.camper.id) ?? false
        VStack {
            HStack {
#if os(macOS)
                if !camperElement.value.rawValue.isEmpty {
                    Button("􀉁") {
                        camperElement.value.rawValue.copy()
                    }
                    .buttonStyle(.plain)
                }
#endif
                Text(camperElement.value.rawValue)

                Spacer()

                let assignment = coordinator.state.groupingState?.pendingAssignments.first(where: { a in
                    a.camper.id == camperElement.camper.id
                })

                let hasAssignment = assignment != nil

                if let dist = camperElement.distance, camperElement.field.includeInGrouping {
                    Text("\(dist)")
                        .foregroundStyle(Color(enum: .positiveDetail))
                } else if camperElement.field.fieldType == .fullName,
                          camperElement.field.isRegistrantData {
                    
                    if let groupID = assignment?.group
                      ?? camperElement.camper.currentGroup,
                       let group = coordinator.state.camp?.group(withID: groupID),
                       let fields = coordinator.state.camp?.groupingFields {
                        let avgDelta = group.averagedDifference(
                            fromCamper: camperElement.camper,
                            groupingFields: fields,
                            equivelences: coordinator.state.camp?.equivelencies ?? [:]
                        )
                        Text("avg∆:\(Int(avgDelta))")
                    }


                } else if camperElement.field.fieldType == .groupNumber,
                          camperElement.field.isRegistrantData {

                    let group = assignment?.group.groupNumber
                      ?? camperElement.camper.currentGroup?.groupNumber
                    let status = camperElement.camper.groupSettingStatus ?? .uploaded
                    
                    let statusMessage = hasAssignment
                    ? "Pending..."
                    : "\(status.rawValue)"

                    let color = if hasAssignment {
                        Color(enum: .actionDetail)
                    } else if status == .edited {
                        Color(enum: .warningDetail)
                    } else {
                        Color(enum: .positiveDetail)
                    }

                    if let group = group {
                        Text("group: \(group) (\(statusMessage))")
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                    }
                }
            }

            Spacer()
        }
        .background {
            Rectangle()
                .fill(
                    isSelected 
                    ? Color(enum: .select)
                    : Color(enum: .plain)
                )
        }
        .onTapGesture {
            guard let campID = coordinator.state.camp?.info.eventNumber else { return }
            coordinator.send(
                event: .grouping(event: .didToggleCamperRow(camper: camperElement.camper, campID: campID))
            )
        }
    }
}

struct CamperRowDataElement: Equatable, Identifiable {
    var id: String {
        "\(camper.id)\(field.fieldName)"
    }

    let camper: Camper
    let field: ReportFieldSetting
    let value: ReportFieldValue
    var distance: Double?
}

extension Array where Element == CamperRowDataElement {
    static func fromCampers(
        _ campers: [Camper],
        selectedCamper: Camper?,
        andFields fields: [ReportFieldSetting]
    ) -> [CamperRowDataElement] {
        var elements = [CamperRowDataElement]()
        for camper in campers {
            for field in fields {

                let value = camper.values[field.fieldName]
                ?? .string(
                    rawValue: "",
                    fieldName: field.fieldName,
                    primary: false
                )
                let selectedsValue = selectedCamper?.values[field.fieldName]
                let distance = selectedsValue?.difference(from: value, with: 1)

                elements.append(
                    CamperRowDataElement(
                        camper: camper,
                        field: field,
                        value: value,
                        distance: distance
                    )
                )
            }
        }

        return elements
    }
}

extension String {
    func copy() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(self, forType: .string)
        #else
        UIPasteboard.general.string = self
        #endif
    }
}
