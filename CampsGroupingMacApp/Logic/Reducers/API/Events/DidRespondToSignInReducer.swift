import Foundation

extension APIEventReducer {
    enum DidRespondToSignInReducer {
        static func handleEvent(
            result: Result<CampAccessAccount, CampsGroupingAPIError>,
            scope: CampsScope,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            guard state.activeFetches.contains(networkCall) else {
                return []
            }
            
            state.activeFetches.remove(networkCall)

            return switch result {
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
            state.accessAccount = account
            state.signInFormState = nil
            state.campScope = scope
            state.navigationMode = .camps

            return [state.beginGetCamps(account: account, scope: scope)]
        }

        private static func didFailSignIn(
            error: CampsGroupingAPIError,
            scope: CampsScope,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.accessAccount = nil
            state.errors.insert(.signIn(error: error, networkCall: networkCall))

            return []
        }
    }
}
