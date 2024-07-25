import Foundation

extension GrouperEvent {
    enum SignInFormEvent: Equatable {
        case didEditSignInForm(
            email: String,
            password: String,
            scope: CampsScope
        )
        case didSelectSignIn(
            email: String,
            password: String,
            scope: CampsScope,
            fetchID: UUID = UUID()
        )
    }
}
