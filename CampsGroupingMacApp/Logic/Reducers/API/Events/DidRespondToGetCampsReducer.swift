import Foundation

extension APIEventReducer {
    enum DidRespondToGetCampsReducer {
        static func handleEvent(
            result: Result<[Camp], CampsGroupingAPIError>,
            account: CampAccessAccount,
            scope: CampsScope,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            if state.activeCampsFetch == fetchID {
                state.campsResult = result
                state.activeCampsFetch = nil
                state.navigationMode = .camps(scope: scope)
            }

            return []
        }
    }
}
