//
//  PotientialMatchDetailView.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/18/24.
//

import SwiftUI

struct PotientialMatchDetailView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State var showDetails = true
    @State var equivelences = [String: Double]()

    var body: some View {
        if let selectedID = coordinator.state.groupingState?.camperCurrentlyBeingGrouped,
           let selectedCamper = coordinator.state.camp?.campers.first(where: { $0.id == selectedID }),
           let camperIDs = coordinator.state.groupingState?.camperSelections {
            
            let campers = camperIDs.compactMap({ camperID in
                coordinator.state.camp?.campers.first(where: { $0.id == camperID })
            })
            let groupingFields = coordinator.state.currentFields
                .filter {
                    $0.includeInGrouping &&
                    !($0.isRegistrantData && $0.fieldType == .fullName)
                }
                .map { $0.fieldName }

            let diffValues = campers.averageValuesDiff(
                from: selectedCamper,
                inFields: groupingFields,
                with: equivelences
            )
            let eachFieldAndDiff = fieldNamesWithDiffs(from: diffValues)
            let totalDiff = diffValues["AVGTOTAL"] ?? nil

            VStack(spacing: 2) {
                Rectangle().fill(.primary).frame(height: 1)
                HStack {
                    Text(campers.count > 1 ? "Average Difference" : campers.first?.name ?? "Selected Camper")
                    Spacer()
                    if let diff = totalDiff {
                        Text("∆: \(diff)")
                    }
                }
                Rectangle().fill(.tertiary).frame(height: 1)
                if showDetails {
                    ForEach(eachFieldAndDiff, id: \.0) { fieldName, diff in
                        HStack {
                            Text(fieldName + ":")
                                .font(.footnote)
                            Spacer()
                            if let diffFound = diff {
                                Text("∆: \(diffFound)")
                                    .font(.footnote)
                            }
                        }
                    }
                }

                Rectangle().fill(.primary).frame(height: 1)
                HStack {
                    Button(showDetails ? "hide comparison" : "show comparison") {
                        showDetails.toggle()
                    }
                    Spacer()
                }
                Rectangle().fill(.primary).frame(height: 1)
                
                let groupIDs = Set(campers.compactMap({ $0.currentGroup })).sorted { id1, id2 in
                    id1.groupNumber < id2.groupNumber
                }

                if !groupIDs.isEmpty {
                    ForEach(groupIDs, id: \.self) { groupID in
                        Button("Group Campers in \(groupID)") {
                            var campersToSet = campers
                            campersToSet.append(selectedCamper)
                            groupCampers(campersToSet, inGroup: groupID)
                        }
                    }

                }
            }
            .padding()
        }
    }

    func groupCampers(_ campers: [Camper], inGroup groupID: GroupIdentification) {
        coordinator.send(
            event: .grouping(
                event: .didAskToGroupCampers(
                    campers: campers,
                    groupID: groupID
                )
            )
        )
    }

    func fieldNamesWithDiffs(from dictionary: [String: Double?]) -> [(String, Double?)] {
        var results = [(String, Double?)]()
        dictionary.keys.forEach {
            let diff: Double? = dictionary[$0] ?? nil
            let name: String = $0
            if name != "AVGTOTAL" {
                results.append((name, diff))
            }
        }
        return results
    }
}

extension Array where Element == Camper {
    func averageValuesDiff(
        from primaryCamper: Camper,
        inFields fieldNames: [String],
        with equivelencies: [String: Double]
    ) -> [String: Double?] {
        let primaryValues = primaryCamper.values(for: fieldNames)
        let otherValueSets = map { camper in
            camper.values(for: fieldNames)
        }

        guard otherValueSets.count > 0 else {
            return [:]
        }

        var results = [String: Double?]()
        var totalResult: Double = 0

        for fieldName in fieldNames {
            var total: Double = 0
            let prime = primaryValues[fieldName] ?? .empty(fieldName: fieldName)
            var setsCount = 0
            otherValueSets.forEach { values in
                let value = values[fieldName] ?? .empty(fieldName: fieldName)
                let diff = value.difference(from: prime, with: equivelencies[fieldName] ?? 1)
                if let diffFound = diff {
                    setsCount += 1
                    total += diffFound
                }
            }
            if setsCount > 0 {
                let average = total / Double(setsCount)
                results[fieldName] = average
                totalResult += average
            } else {
                results[fieldName] = nil
            }
        }
        results["AVGTOTAL"] = totalResult

        return results
    }

    func maxAverageValuesDiff(
        from primaryCamper: Camper,
        inFields fieldNames: [String],
        with equivelencies: [String: Double]
    ) -> Double {
        let primaryValues = primaryCamper.values(for: fieldNames)
        let otherValueSets = map { camper in
            camper.values(for: fieldNames)
        }

        guard otherValueSets.count > 0 else {
            return 0
        }

        var results: [Double] = []

        for fieldName in fieldNames {
            var total: Double = 0
            let prime = primaryValues[fieldName] ?? .empty(fieldName: fieldName)
            otherValueSets.forEach { values in
                let value = values[fieldName] ?? .empty(fieldName: fieldName)
                let diff = value.difference(from: prime, with: equivelencies[fieldName] ?? 1)
                if let diffFound = diff {
                    total += diffFound
                }
            }

            results.append(total)
        }

        return results.max() ?? 0
    }
}

private extension Camper {
    func values(for fieldNames: [String]) -> [String: ReportFieldValue] {
        var filtered = [String: ReportFieldValue]()

        fieldNames.forEach({ fieldName in
            let match = values[fieldName] ?? .empty(fieldName: fieldName)
            filtered[fieldName] = match
        })

        return filtered
    }
}
