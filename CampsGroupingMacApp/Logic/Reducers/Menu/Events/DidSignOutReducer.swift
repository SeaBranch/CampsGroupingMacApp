import Foundation

extension MenuEventReducer {
    enum DidSignOutReducer {
        static func handleEvent(
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.signInFormState = SignInFormState()
            state.accessAccount = nil
            state.activeSignIn = nil
            state.activeSignInError = nil

            return []
        }
    }
}
