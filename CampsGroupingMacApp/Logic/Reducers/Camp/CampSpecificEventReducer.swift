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
            let report = camp.reportID?.report
            state.report = report
            state.navigationMode = .report(report: report, camp: camp, scope: scope)

            return []
        case .didSelectViewGrouping(let camp, let scope, let fetchID):
            return DidSelectViewGroupingReducer.handleEvent(
                camp: camp,
                fetchID: fetchID,
                state: &state
            )

        case .didChangeField(let field):
            state.report = state.report?.withChangedField(field)

            return []
        }
    }
}
