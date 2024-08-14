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
            let campers = coordinator.state.camp?.campers ?? []
            ForEach(
            campers.prioritizingFlaggedFields()
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
                    camperRows: (coordinator.state.camp?.campers) ?? [],
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
    func camperView(_ camper: Camper) -> some View {
        VStack {
            Text(camper.name)
                .font(.title3)
            Text(camper.values.crossroadsSite ?? "")
                .font(.footnote)
        }.onTapGesture {
            // TODO: hanle tap
        }
    }
}

private extension Array where Element == Camper {
    func prioritizingFlaggedFields(sortByFieldName: String = "", ascending: Bool = true) -> [Camper] {
        var prioritized = filter { $0.requiresDirectHandling }
            .sortByFieldName(fieldName: sortByFieldName, ascending: ascending)
        let additionalRows = filter { !$0.requiresDirectHandling }
            .sortByFieldName(fieldName: sortByFieldName, ascending: ascending)

        prioritized.append(contentsOf: additionalRows)
        return prioritized
    }

    func sortByFieldName(fieldName: String, ascending: Bool) -> [Camper] {
        guard !fieldName.isEmpty else { return self }
        let valuesWithField = filter { camper in
            !(camper.values[fieldName]?.rawValue ?? "").isEmpty
        }
        let valuesWithoutField = filter { camper in
            (camper.values[fieldName]?.rawValue ?? "").isEmpty
        }

        var values = valuesWithField.sorted { row1, row2 in
            let row1Val = row1.values[fieldName]?.rawValue ?? ""
            let row2Val = row2.values[fieldName]?.rawValue ?? ""
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
