//
//  AutoGrouper.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/21/24.
//

import Foundation

class AutoGrouper: ActionHandler<GrouperEventSpace> {
    open override func handle(action: GrouperAction, handleEvent: @escaping (GrouperEvent) -> Void) {
        if case GrouperAction.generateAutoGrouping(
            let state,
            let assigneeFilters,
            let groupMemberFilters,
            let equivelencies,
            let minSize,
            let sizeCap
        ) = action,
           let campers = state.camp?.campers,
           let groups = state.camp?.groups,
           let fields = state.camp?.groupingFields {
            DispatchQueue.processing.async {
                let assignments = self.autoGroupings(
                    for: campers,
                    in: groups,
                    usingFields: fields,
                    assigneeFilters: assigneeFilters,
                    groupMemberFilters: groupMemberFilters,
                    equivelencies: equivelencies,
                    minSize: minSize,
                    sizeCap: sizeCap
                )

                DispatchQueue.main.async {
                    handleEvent(.grouping(event: .didGenerateAutoGrouping(
                        assigneeFilters: assigneeFilters,
                        groupMemeberFilter: groupMemberFilters,
                        equivelencies: equivelencies,
                        grouping: assignments
                    )))
                }
            }
        }
    }

    func autoGroupings(
        for campers: [Camper],
        in groups: [CampGroup],
        usingFields fields: [String],
        assigneeFilters: [FilterStep],
        groupMemberFilters: [FilterStep],
        equivelencies: [String: Double],
        minSize: Int,
        sizeCap: Int
    ) -> [CamperAssignment] {
        let filteredGroups = groups.filter { group in
            group.attendeeCount < minSize
        }

        var existingAssignments: [CamperAssignment] = []

        for camper in campers {
            if let grouping = autoGrouping(
                for: camper,
                in: filteredGroups.map({ $0.withAssignments(existingAssignments) }),
                usingFields: fields,
                assigneeFilters: assigneeFilters,
                groupMemberFilters: groupMemberFilters,
                equivelencies: equivelencies,
                minSize: minSize,
                sizeCap: sizeCap
            ) {
                existingAssignments.append(grouping)
            }
        }

        return existingAssignments
    }

    func autoGrouping(
        for camper: Camper,
        in groups: [CampGroup],
        usingFields fields: [String],
        assigneeFilters: [FilterStep],
        groupMemberFilters: [FilterStep],
        equivelencies: [String: Double],
        minSize: Int,
        sizeCap: Int
    ) -> CamperAssignment? {
        var filteredGroups = groups.filter { group in
            group.campers.count < sizeCap
        }

        var addedCap = 1
        while filteredGroups.count < max(3, groups.count / 10) {
            filteredGroups = groups.filter { group in
                group.campers.count < sizeCap
            }
            addedCap += 1
        }

        return filteredGroups.map { group in
            let diff = group.averagedDifference(
                fromCamper: camper,
                groupingFields: fields,
                equivelences: equivelencies
            )
            let maxDiff = group.maxAveragedDifference(
                fromCamper: camper,
                groupingFields: fields,
                equivelences: equivelencies
            )
            
            return CamperAssignmentOption(
                averageDiff: diff,
                maxAveragedDiff: maxDiff,
                assignment: CamperAssignment(camper: camper, group: group.groupID)
            )
        }.bestAverageDiff
    }
}

private struct CamperAssignmentOption {
    let averageDiff: Double
    let maxAveragedDiff: Double
    let assignment: CamperAssignment
}

private extension Array where Element == CamperAssignmentOption {
    var bestAverageDiff: CamperAssignment? {
        self.sorted { a1, a2 in
            a1.averageDiff < a2.averageDiff
        }.first?.assignment
    }

    var bestMaxAverageDiff: CamperAssignment? {
        self.sorted { a1, a2 in
            a1.maxAveragedDiff < a2.maxAveragedDiff
        }.first?.assignment
    }
}

private extension CampGroup {
    func withAssignments(_ assignments: [CamperAssignment]) -> CampGroup {
        var newGroup = self

        let newCampers = assignments.filter({ assignment in
            assignment.group == self.groupID
        }).map({ $0.camper })

        newGroup.campers.append(contentsOf: newCampers)

        return newGroup
    }
}
