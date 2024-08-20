import Foundation

extension APIEventReducer {
    enum DidRespondToGetGroupsReducer {
        static func handleEvent(
            result: Result<[CampGroupDTO], CampsGroupingAPIError>,
            camp: Camp,
            scope: CampsScope,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            if state.activeFetches.contains(networkCall) {
                state.activeFetches.remove(networkCall)
                switch result {
                case .success(let groups):
                    state.camps = state.camps.map {
                        if $0.info.eventNumber == camp.info.eventNumber {
                            var updated = $0
                            updated.groupsRecord = groups
                            return updated
                        } else {
                            return $0
                        }
                    }

                    state.errors = state.errors.filter { error in
                        if case .groups = error {
                            false
                        } else {
                            true
                        }
                    }

                case .failure(let error):
                    state.errors = state.errors.filter { error in
                        if case .groups = error {
                            false
                        } else {
                            true
                        }
                    }
                    state.errors.insert(.groups(error: error, networkCall: networkCall))
                }
            }

            return []
        }
    }
}
