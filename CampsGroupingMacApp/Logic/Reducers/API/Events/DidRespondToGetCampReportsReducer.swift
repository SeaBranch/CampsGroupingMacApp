import Foundation

extension APIEventReducer {
    enum DidRespondToGetCampReportsReducer {
        static func handleEvent(
            result: GetCampReportsResult,
            requestData: GetCampReportsData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)
            switch result {
            case .success(let reportAddresses):
                state.camps = state.camps.map({ camp in
                    if let reportID = reportAddresses.first(where: { address in
                        address.campID == "\(camp.info.eventNumber)"
                    })?.reportID {
                        return camp.withNewReportID(reportID: reportID)
                    } else {
                        return camp
                    }
                })
            case .failure(let error):
                state.errors = state.errors.filter { error in
                    if case .campReports = error {
                        false
                    } else {
                        true
                    }
                }
                state.errors.insert(.campReports(error: error, networkCall: networkCall))
            }

            return []
        }
    }
}

