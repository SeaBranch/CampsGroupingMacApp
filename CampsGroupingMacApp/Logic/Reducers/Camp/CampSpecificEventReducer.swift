//
//  CampSpecificEventReducer.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/25/24.
//

import Foundation

enum CampSpecificEventReducer {
    static func handle(
        event: CampSpecificEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .didSelectManageReport(let camp, let scope):
            return [.getCampReport(camp, scope)]
        case .didGetReportForCamp(let report, let camp, let scope):
            state.currentReport = report
            state.navigationMode = .report(report: report, camp: camp, scope: scope)

            return [.getReportFormatForCamp(camp, report)]
        case .didSelectViewGrouping(let camp, let scope, let fetchID):
            return DidSelectViewGroupingReducer.handleEvent(
                camp: camp,
                fetchID: fetchID,
                state: &state
            )

        case .didChangeField(let field):
            guard let report = state.currentReport else { return [] }
            return [.updateReportFormatWithField(report, field)]

        case .didUpdateReport(let report):
            state.currentReport = report
            
            return []
        case .didSelectFieldTypeButtonForField(let field):
            state.fieldTypeFieldBeingChanged = field
            return []

        case .didSelectBeginGrouping(let campers, let camp, let scope):
            state.campers = campers
            state.navigationMode = .grouping(
                campers: campers,
                camp: camp,
                scope: scope
            )

            return [] // TODO: sync report settings

        case .didSelectCamperRow(let camper, let section):
            return []
        case .didSelectFilterOptions(let section):
            return []
        case .didChangeFilterOptions(let newOptions):
            return []
        case .didSelectCompareMode(let compareMode):
            return []
        case .didSelectGroupRow(let groupID, let section):
            return []
        }
    }
}
