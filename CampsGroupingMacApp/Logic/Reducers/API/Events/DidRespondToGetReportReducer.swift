import Foundation

extension APIEventReducer {
    enum DidRespondToGetReportReducer {
        static func handleEvent(
            result: Result<Report, CampsGroupingAPIError>,
            campSettings: CampSettings,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)

            switch result {
            case .success(let report):
                return didGetReport(
                    report: report,
                    campSettings: campSettings,
                    networkCall: networkCall,
                    state: &state
                )
            case .failure(let error):
                return didFailToGetReport(
                    error: error,
                    campSettings: campSettings,
                    networkCall: networkCall,
                    state: &state
                )
            }
        }

        static func didGetReport(
            report: Report,
            campSettings: CampSettings,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            guard var newCamp = state.camps.first(where: { camp in
                camp.info.eventNumber == campSettings.report.campEventNumber
            }) else {
                return []
            }

            newCamp.report = report
            state.errors = state.errors.filter { error in
                if case .campReport = error {
                    false
                } else {
                    true
                }
            }
            state.camps = state.camps.map {
                if $0.info.eventNumber == newCamp.info.eventNumber {
                    newCamp
                } else {
                    $0
                }
            }

            return []
        }

        static func didFailToGetReport(
            error: CampsGroupingAPIError,
            campSettings: CampSettings,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.errors = state.errors.filter { error in
                if case .campReport = error {
                    false
                } else {
                    true
                }
            }

            state.errors.insert(.campReport(error: error, networkCall: networkCall))

            return []
        }
    }
}
