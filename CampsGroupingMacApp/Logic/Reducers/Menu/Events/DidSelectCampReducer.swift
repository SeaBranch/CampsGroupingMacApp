import Foundation

extension MenuEventReducer {
    enum DidSelectCampReducer {
        static func handleEvent(
            camp: Camp,
            scope: CampsScope,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.selectedCamp = camp.info.eventNumber
            state.navigationMode = .camps

            return if let settings = camp.campSettings {
                [
                    state.beginGetReportForCamp(campSettings: settings),
                    state.beginGetReportFormatForCamp(campSettings: settings),
                    state.beginGetCamperSettingsForCamp(camp: camp),
                    state.beginGetGroupsForCamp(camp: camp, scope: scope)
                ]
            } else {
                [
                    state.beginGetCamperSettingsForCamp(camp: camp),
                    state.beginGetGroupsForCamp(camp: camp, scope: scope)
                ]
            }
        }
    }
}
