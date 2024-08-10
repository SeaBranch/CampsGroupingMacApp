import Foundation

extension NetworkActionHandler {
    func handleSignIn(
        username: String,
        password: String,
        scope: CampsScope,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        signInLogicController.signIn(email: username, password: password, scope: scope) { result in
            handleEvent(
                .api(event: .didRespondToSignIn(result: result, scope: scope, networkCall: networkCall))
            )
        }
    }
}
