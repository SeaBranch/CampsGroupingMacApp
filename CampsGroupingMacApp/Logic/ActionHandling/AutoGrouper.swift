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

            print("""
            AUTOGROUP:
            minSize: \(minSize)
            sizeCap: \(sizeCap)
            """
            )

            DispatchQueue.global().async {
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
        let groupsToUse = groups.filter { group in
            group.attendeeCount < minSize// && group.attendeeCount > 0
            // && group.type == .tripCaptain // TODO: handle this later
        }

        var filteredGroups = groupsToUse

        var existingAssignments: [CamperAssignment] = []
        var campersLeftToGroup = campersLeftToGroup(
            for: campers,
            in: groups,
            existingAssignments: existingAssignments
        )
        let totalAutoGrouped = campersLeftToGroup.count

        while !campersLeftToGroup.isEmpty {
            
            let remaining = campersLeftToGroup.count

            DispatchQueue.global().async {
//                GLOBAL_MESSAGES["CAMPERS LEFT TO AUTOGROUP"] = "\(remaining)/\(totalAutoGrouped)"
                print("CAMPERS LEFT TO AUTOGROUP: \(remaining)/\(totalAutoGrouped) in \(groupsToUse.count) groups")
            }

            for group in groupsToUse {
                // add camper that is closest to group and their groupmates
                let ag = autoGrouping(
                    for: group,
                    with: campersLeftToGroup,
                    camperGroups: groups,
                    usingFields: fields,
                    assigneeFilters: assigneeFilters,
                    groupMemberFilters: groupMemberFilters,
                    equivelencies: equivelencies,
                    minSize: minSize,
                    sizeCap: sizeCap
                )

                existingAssignments.append(
                    contentsOf: ag
                )

                filteredGroups = groupsToUse.filter { group in
                    group.withAssignments(existingAssignments).campers.count < sizeCap
                }

                var extraCap = 1
                while filteredGroups.isEmpty {
                    filteredGroups = groupsToUse.filter { group in
                        group.withAssignments(existingAssignments).campers.count < (sizeCap + extraCap)
//                        &&
//                        group.type == .tripCaptain
                    }
                    extraCap += 1
                }

                campersLeftToGroup = self.campersLeftToGroup(
                    for: campers,
                    in: groups,
                    existingAssignments: existingAssignments
                )
            }
        }

        return existingAssignments
    }

    private func campersLeftToGroup(
        for campers: [Camper],
        in groups: [CampGroup],
        existingAssignments: [CamperAssignment]
    ) -> [Camper] {
        campers.filter({ camper in
            let cGroup = groups.first(where: { $0.groupID == camper.currentGroup })
//            if cGroup?.type == .tripCaptain { return false }
            if cGroup != nil { return false }
            if existingAssignments
                .map({ $0.camper.id })
                .contains(camper.id) {
                return false
            }
            return !camper.requiresDirectHandling && camper.currentGroup == nil
        })
    }

    func autoGrouping(
        for group: CampGroup,
        with campers: [Camper],
        camperGroups: [CampGroup],
        usingFields fields: [String],
        assigneeFilters: [FilterStep],
        groupMemberFilters: [FilterStep],
        equivelencies: [String: Double],
        minSize: Int,
        sizeCap: Int
    ) -> [CamperAssignment] {
        let filtered = campers.filter({ camper in
            //            let cGroup = camperGroups.first(where: { $0.groupID == camper.currentGroup })
            //            if cGroup?.type == .tripCaptain { return false }
            //            if (cGroup?.campers ?? []).count + group.campers.count > sizeCap { return false }
            return !camper.requiresDirectHandling && camper.currentGroup == nil
        })

        let camper = filtered.map { camper in
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
        var assignments = [camper].compactMap { $0 }

        // TODO: handle non trip captain groups here
//        if let assigned = camper, let cGroup = camperGroups.first(where: { $0.groupID == assigned.camper.currentGroup }) {
//            for otherCamper in cGroup.campers {
//                assignments.append(CamperAssignment(camper: otherCamper, group: assigned.group))
//            }
//        }

        return assignments
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
