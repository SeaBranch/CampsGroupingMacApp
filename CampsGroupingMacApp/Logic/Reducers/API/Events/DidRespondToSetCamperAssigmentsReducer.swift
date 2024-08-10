import Foundation

extension APIEventReducer {
    enum DidRespondToSetCamperAssigmentsReducer {
        static func handleEvent(
            result: SetCamperAssigmentsResult,
            requestData: SetCamperAssigmentsData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)
            switch result {
            case .success:
                return [state.beginGetCamperSettingsForCamp(camp: requestData.camp)]
            case .failure(let error):
                state.errors = state.errors.filter { error in
                    if case .updateCampers = error {
                        false
                    } else {
                        true
                    }
                }
                state.errors.insert(.updateCampers(error: error, networkCall: networkCall))

                return []
            }
        }
    }
}
