import Foundation

extension APIEventReducer {
    enum RetryNetworkCallReducer {
        static func handleEvent(
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            switch networkCall {
            case .signIn:
                return []
            case .camps:
                guard let account = state.accessAccount,
                      let scope = state.campScope else {
                    return []
                }

                return [state.beginGetCamps(account: account, scope: scope)]
            case .campReports:
                return [state.beginGetReports()]
            case .campReport:
                guard let camp = state.camp,
                      let settings = camp.campSettings
                else {
                    return []
                }

                return [state.beginGetReportForCamp(campSettings: settings)]
            case .campReportFormat:
                guard let camp = state.camp,
                      let settings = camp.campSettings
                else {
                    return []
                }

                return [state.beginGetReportFormatForCamp(campSettings: settings)]
            case .camperSettings:
                guard let camp = state.camp
                else {
                    return []
                }

                return [state.beginGetCamperSettingsForCamp(camp: camp)]
            case .setReport:
                return []
            case .updateReportFormat:
                return []
            case .setCamperAssigments:
                return []
            case .groups:
                if let camp = state.camp {
                    let scope = camp.scope

                    return [state.beginGetGroupsForCamp(camp: camp, scope: scope)]
                } else {
                    return []
                }
            case .uploadGroupAssignment:
                return []
            case .markAssignmentAsUploaded:
                return []
            }
        }
    }
}
