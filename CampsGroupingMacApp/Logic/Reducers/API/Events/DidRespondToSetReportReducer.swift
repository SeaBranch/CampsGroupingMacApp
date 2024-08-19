import Foundation

extension APIEventReducer {
    enum DidRespondToSetReportReducer {
        static func handleEvent(
            result: SetReportResult,
            requestData: SetReportData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)

            switch result {
            case .success:
                return [state.beginGetReports()]
            case .failure(let error):
                state.errors = state.errors.filter { error in
                    if case .setReport = error {
                        false
                    } else {
                        true
                    }
                }
                state.errors.insert(.setReport(error: error, networkCall: networkCall))
            }

            return []
        }
    }
}
