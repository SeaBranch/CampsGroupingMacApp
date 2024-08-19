import Foundation

extension APIEventReducer {
    enum DidRespondToSetCamperAssigmentsReducer {
        static func handleEvent(
            result: SetCamperAssigmentsResult,
            requestData: UpdateCamperAssigmentsData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)
            switch result {
            case .success(let camperSettings):
                state.applyCamperSettings(for: requestData.camp.info.eventNumber, settings: camperSettings)
                return []
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
