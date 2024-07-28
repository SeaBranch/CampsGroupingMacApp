import SwiftUI

struct CampersToBeGroupedView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State private var searchQuery = ""

    var body: some View {
        NavigationStack {
            List {
                if searchQuery.isEmpty {
                    prioritizedCampers()
                } else {
                    filteredCampers(searchQuery: searchQuery)
                }
            }
        }
        .searchable(
            text: $searchQuery,
            placement: .sidebar,
            prompt: Text("Search Campers Needing Grouped"))
    }

    @ViewBuilder
    func prioritizedCampers() -> some View {
        if searchQuery.isEmpty {
            ForEach(
            coordinator.state.campers.prioritizingFlaggedFields()
            ) { camperRow in
                camperView(camperRow)
            }
        }
    }

    @ViewBuilder
    func filteredCampers(searchQuery: String) -> some View {
        if !searchQuery.isEmpty {
            ForEach(
                Search.CamperResult(
                    query: searchQuery,
                    camperRows: coordinator.state.campers,
                    fullNamesOnly: true
                )
                .resultingCampers
                .map { $0.camper }
            ) { camperRow in
                camperView(camperRow)
            }
        }
    }

    @ViewBuilder
    func camperView(_ camperRow: CamperRow) -> some View {
        VStack {
            Text(camperRow.camper.name)
                .font(.title3)
            Text(camperRow.row.crossroadsSite ?? "")
                .font(.footnote)
        }.onTapGesture {
            coordinator.send(event: .camp(event: .didSelectCamperRow(camper: camperRow.camper, inSection: .camper)))
        }
    }
}

private extension Array where Element == CamperRow {
    func prioritizingFlaggedFields(sortByFieldName: String = "", ascending: Bool = true) -> [CamperRow] {
        var prioritized = filter { $0.camper.requiresDirectHandling }
            .sortByFieldName(fieldName: sortByFieldName, ascending: ascending)
        var additionalRows = filter { !$0.camper.requiresDirectHandling }
            .sortByFieldName(fieldName: sortByFieldName, ascending: ascending)

        prioritized.append(contentsOf: additionalRows)
        return prioritized
    }

    func sortByFieldName(fieldName: String, ascending: Bool) -> [CamperRow] {
        guard !fieldName.isEmpty else { return self }

        var valuesWithField = filter {
            !($0.row[fieldName]??.rawValue ?? "").isEmpty
        }

        var valuesWithoutField = filter {
            ($0.row[fieldName]??.rawValue ?? "").isEmpty
        }

        var values = valuesWithField.sorted { row1, row2 in
            let row1Val = row1.row[fieldName]??.rawValue ?? ""
            let row2Val = row2.row[fieldName]??.rawValue ?? ""
            return if ascending {
                row1Val > row2Val
            } else {
                row1Val < row2Val
            }
        }

        values.append(contentsOf: valuesWithoutField)

        return values
    }
}
