import Foundation

extension APIEventReducer {
    enum DidRespondToSignInReducer {
        static func handleEvent(
            result: Result<CampAccessAccount, CampsGroupingAPIError>,
            scope: CampsScope,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            switch result {
            case .success(let account):
                didSignIn(
                    account: account,
                    scope: scope,
                    networkCall: networkCall,
                    state: &state
                )
            case .failure(let error):
                didFailSignIn(
                    error: error,
                    scope: scope,
                    networkCall: networkCall,
                    state: &state
                )
            }
        }

        private static func didSignIn(
            account: CampAccessAccount,
            scope: CampsScope,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            if state.activeFetches.contains(networkCall) {
                state.activeFetches.remove(networkCall)
                state.accessAccount = account
                state.signInFormState = nil
                state.navigationMode = .camps

                return [.getCamps(account: account, scope: scope)]
            }

            return []
        }

        private static func didFailSignIn(
            error: CampsGroupingAPIError,
            scope: CampsScope,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            if state.activeFetches.contains(networkCall) {
                state.activeFetches.remove(networkCall)
                state.accessAccount = nil
                state.errors.insert(.signIn(error: error, networkCall: networkCall))
            }

            return []
        }
    }
}
