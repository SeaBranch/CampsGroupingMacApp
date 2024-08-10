import Foundation

extension APIEventReducer {
    enum DidRespondToGetCampsReducer {
        static func handleEvent(
            result: Result<[CampInfo], CampsGroupingAPIError>,
            account: CampAccessAccount,
            scope: CampsScope,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            if state.activeFetches.contains(networkCall) {
                state.activeFetches.remove(networkCall)
                switch result {
                case .success(let camps):
                    state.camps = camps.map { Camp(info: $0, scope: scope) }
                    state.errors = state.errors.filter { error in
                        if case .camps = error {
                            false
                        } else {
                            true
                        }
                    }
                    state.navigationMode = .camps

                    return [state.beginGetReports()]
                case .failure(let error):
                    state.errors = state.errors.filter { error in
                        if case .camps = error {
                            false
                        } else {
                            true
                        }
                    }
                    state.errors.insert(.camps(error: error, networkCall: networkCall))
                }
            }

            return []
        }
    }
}
