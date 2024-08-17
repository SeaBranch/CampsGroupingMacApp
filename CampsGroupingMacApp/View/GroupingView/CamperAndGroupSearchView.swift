import SwiftUI

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
                Text(camperElement.value.rawValue)

                Spacer()

                if let dist = camperElement.distance {
                    Text("\(dist)")
                        .foregroundStyle(.green)
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
