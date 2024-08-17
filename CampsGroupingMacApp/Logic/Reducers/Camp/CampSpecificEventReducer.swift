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
        case .didSelectManageReport(camp: let camp):
            DidSelectManageReportReducer.handle(camp: camp, state: &state)
        case .didSelectViewGrouping(camp: let camp):
            DidSelectViewGroupingReducer.handle(camp: camp, state: &state)
        case .reportEvent(event: let event):
            ReportEventReducer.handle(event: event, state: &state)
        }
    }
}

enum DidSelectManageReportReducer {
    static func handle(
        camp: Camp,
        state: inout GrouperState
    ) -> [GrouperAction] {
        guard let campSettings = camp.campSettings else {
            return []
        }

        state.navigationMode = .report
        return [state.beginGetReportForCamp(campSettings: campSettings)]
    }
}

enum DidSelectViewGroupingReducer {
    static func handle(
        camp: Camp,
        state: inout GrouperState
    ) -> [GrouperAction] {
        state.navigationMode = .grouping
        return []
    }
}

enum ReportEventReducer {
    static func handle(
        event: GrouperEvent.ReportFormattingEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .didChangeReportIdentifier(let string):
            
            return []
        case .didChangeReportFieldSetting(let setting):
            guard let selectedCamp = state.selectedCamp else {
                return []
            }

            let change = CampChange.formatChange(setting)
            state.camps = state.camps.applyChange(change, toCampNumber: selectedCamp)
            return []
        case .didChangeSearchQuery(let section, let query):
            return []
        }
    }
}
