import Foundation

extension APIEventReducer {
    enum DidRespondToGetReportReducer {
        static func handleEvent(
            result: Result<Report, CampsGroupingAPIError>,
            camp: Camp,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            switch result {
            case .success(let report):
                didGetReport(
                    report: report,
                    camp: camp,
                    networkCall: networkCall,
                    state: &state
                )
            case .failure(let error):
                didFailToGetReport(
                    error: error,
                    camp: camp,
                    networkCall: networkCall,
                    state: &state
                )
            }
        }

        static func didGetReport(
            report: Report,
            camp: Camp,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            var newCamp = camp
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
            camp: Camp,
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
