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
            state.activeSignIn = fetchID
            return [.signIn(username: email, password: password, scope: scope, fetchID: fetchID)]
        }
    }
}
