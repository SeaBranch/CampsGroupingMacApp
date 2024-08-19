import Foundation

extension SignInFormEventReducer {
    enum DidSelectSignInReducer {
        static func handleEvent(
            email: String,
            password: String,
            scope: CampsScope,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.errors = state.errors.filter({ error in
                if case .signIn = error {
                    false
                } else {
                    true
                }
            })

            return [state.beginSignIn(username: email, password: password, scope: scope)]
        }
    }
}
