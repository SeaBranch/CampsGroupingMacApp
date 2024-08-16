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
                        HStack {
                            Text(field.fieldName)
                            Spacer()
                        }
                    }
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        prioritizedCampers(fields: groupingFields)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    func prioritizedCampers(fields: [ReportFieldSetting]) -> some View {
        let campers = coordinator.state.camp?.campers ?? []
        let filtered = campers.filteredBySearch(
            query: searchQuery,
            exclude: coordinator.state.groupingState?.camperCurrentlyBeingGrouped
        )

        ForEach(
            [CamperRowDataElement]
                .fromCampers(
                    filtered,
                    selectedCamper: coordinator.state.selectedCamper,
                    andFields: fields
                )
        ) { camperRow in
            camperView(camperRow)
        }
    }

    @ViewBuilder
    func camperView(_ camperElement: CamperRowDataElement) -> some View {
        let isSelected = coordinator.state.groupingState?.camperSelections
            .contains(camperElement.camper.id) ?? false
        let groupingFields = coordinator.state.currentFields
            .filter { $0.showInTable }
        HStack {
            Text(camperElement.value.rawValue)
                .foregroundStyle(isSelected ? .blue : .primary)

            Spacer()

            if let dist = camperElement.distance {
                Text("\(dist)")
                    .foregroundStyle(.green)
            }
        }
        .background {
            Rectangle()
                .fill(
                    isSelected 
                    ? Color(cgColor: CGColor(red: 0.9, green: 0.9, blue: 1, alpha: 1))
                    : Color(cgColor: CGColor(red: 1, green: 1, blue: 1, alpha: 0.1))
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
