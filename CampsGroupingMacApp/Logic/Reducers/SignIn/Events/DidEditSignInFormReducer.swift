import Foundation

extension SignInFormEventReducer {
    enum DidEditSignInFormReducer {
        static func handleEvent(
            email: String,
            password: String,
            scope: CampsScope,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.signInFormState = SignInFormState(email: email, password: password, scope: scope)

            return []
        }
    }
}
