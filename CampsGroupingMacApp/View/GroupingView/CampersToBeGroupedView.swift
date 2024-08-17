import SwiftUI

struct CampersToBeGroupedView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State private var searchQuery = ""

    var body: some View {
        NavigationStack {
            Button("Back") {
                if let camp = coordinator.state.camp {
                    coordinator.send(event: .menu(event: .didSelectCamp(camp: camp, scope: camp.scope)))
                } else if let scope = coordinator.state.campScope {
                    coordinator.send(event: .menu(event: .didGoBackToCamps(scope: scope)))
                }
            }

            List {
                prioritizedCampers()
            }
        }
        .searchable(
            text: $searchQuery,
            placement: .sidebar,
            prompt: Text("Search Campers Needing Grouped"))
    }

    @ViewBuilder
    func prioritizedCampers() -> some View {
        let campers = coordinator.state.camp?.campers ?? []
        ForEach(
            campers.filteredBySearch(query: searchQuery).filter({ camper in
                camper.currentGroupID == nil
            })
        ) { camperRow in
            camperView(camperRow)
        }
    }

    @ViewBuilder
    func camperView(_ camper: Camper) -> some View {
        let isSelected = coordinator.state.groupingState?.camperCurrentlyBeingGrouped == camper.id
        let isFlagged = camper.requiresDirectHandling

        HStack {
            VStack {
                HStack {
                    Text(camper.name)
                        .font(.title3)
                    Spacer()
                }
                let groupingFields = coordinator.state.currentFields
                    .filter { $0.includeInGrouping }
                    .map { $0.fieldName }

                let values = camper.values
                    .filter { 
                        groupingFields.contains($0.key) &&
                        !$0.value.rawValue.isEmpty
                    }
                    .sorted(by: { e1, e2 in
                        e1.key < e2.key
                    })
                    .map { $0.value }


                ForEach(values, id: \.rawValue) { groupingValue in
                    HStack {
                        Text(groupingValue.rawValue)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }

            Spacer()
        }
        .background {
            Rectangle()
                .fill(backingColor(isSelected: isSelected, isFlagged: isFlagged))
        }
        .onTapGesture {
            coordinator.send(
                event: .grouping(event: .didSelectCamperToGroup(
                    camper: camper
                ))
            )
        }
    }

    func backingColor(isSelected: Bool, isFlagged: Bool) -> Color {
        if isSelected {
            Color(enum: .select)
        } else if isFlagged {
            Color(enum: .flagged)
        } else {
            Color(enum: .plain)
        }
    }
}

extension Array where Element == Camper {
    func prioritizingFlaggedFields(sortByFieldName: String = "", ascending: Bool = true) -> [Camper] {
        var prioritized = filter { $0.requiresDirectHandling }
            .sortByFieldName(fieldName: sortByFieldName, ascending: ascending)
        let additionalRows = filter { !$0.requiresDirectHandling }
            .sortByFieldName(fieldName: sortByFieldName, ascending: ascending)

        prioritized.append(contentsOf: additionalRows)
        return prioritized
    }

    func filteredBySearch(
        query: String,
        sortByFieldName: String = "",
        ascending: Bool = true,
        exclude: Int? = nil
    ) -> [Camper] {
        filter { possible in
            if possible.name.isInQuery(query) {
                if let excluded = exclude, possible.id == excluded {
                    return false
                }

                return true
            }
            
            return false
        }
        .prioritizingFlaggedFields(sortByFieldName: sortByFieldName, ascending: ascending)
    }

    func filteredByFiltered(_ fieldFilter: FieldFilter) -> [Camper] {
        filter { possible in
            switch fieldFilter {
            case .all(let field):
                return true
            case .exact(let expectedValue, let field):
                return possible.values[field.fieldName]?.rawValue == expectedValue
            case .bool(let expectedValue, let field):
                switch possible.values[field.fieldName] {
                case .bool(let value, _, _, _):
                    return value == expectedValue
                default:
                    return expectedValue == nil
                }
            case .search(let query, let field):
                return possible.values[field.fieldName]?.rawValue.isInQuery(query) == true
            case .range(let from, let to, let field):
                switch possible.values[field.fieldName] {
                case .int(let value, _, _, _):
                    if let value = value {
                        return value >= from && value <= to
                    } else {
                        return false
                    }
                default:
                    return false
                }
            }
        }
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

extension String {
    func isInQuery(_ query: String) -> Bool {
        if query.isEmpty { return true }

        var subString = self
        for char in query {
            if let range = subString.range(of: "\(char)", options: .literal) {
                subString = "\(subString[range.upperBound...])"
            } else {
                return false
            }
        }
        return true
    }
}
