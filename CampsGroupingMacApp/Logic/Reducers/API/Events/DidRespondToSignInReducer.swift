import Foundation

extension APIEventReducer {
    enum DidRespondToSignInReducer {
        static func handleEvent(
            result: Result<CampAccessAccount, CampsGroupingAPIError>,
            scope: CampsScope,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            switch result {
            case .success(let account):
                didSignIn(
                    account: account,
                    scope: scope,
                    fetchID: fetchID,
                    state: &state
                )
            case .failure(let error):
                didFailSignIn(
                    error: error,
                    scope: scope,
                    fetchID: fetchID,
                    state: &state
                )
            }
        }
    }

    static func didSignIn(
        account: CampAccessAccount,
        scope: CampsScope,
        fetchID: UUID,
        state: inout GrouperState
    ) -> [GrouperAction] {
        if state.activeSignIn == fetchID {
            state.activeSignIn = nil
            state.activeCampsFetch = fetchID
            state.accessAccount = account
            state.signInFormState = nil
            state.navigationMode = .camps(scope: scope)

            return [.getCamps(account: account, scope: scope, fetchID: fetchID)]
        }

        return []
    }

    static func didFailSignIn(
        error: CampsGroupingAPIError,
        scope: CampsScope,
        fetchID: UUID,
        state: inout GrouperState
    ) -> [GrouperAction] {
        if state.activeSignIn == fetchID {
            state.activeSignIn = nil
            state.accessAccount = nil
            state.activeSignInError = error
        }

        return []
    }
}
