import Foundation

enum SignInFormEventReducer {
    static func handle(
        event: SignInFormEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .didEditSignInForm(let email, let password, let scope):
            DidEditSignInFormReducer.handleEvent(
                email: email,
                password: password,
                scope: scope,
                state: &state
            )
        case .didSelectSignIn(let email, let password, let scope, let fetchID):
            DidSelectSignInReducer.handleEvent(
                email: email,
                password: password,
                scope: scope,
                fetchID: fetchID,
                state: &state
            )
        }
    }
}
