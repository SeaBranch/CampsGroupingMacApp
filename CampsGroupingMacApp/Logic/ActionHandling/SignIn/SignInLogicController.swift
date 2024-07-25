import Foundation

private let endpoint = CampsGroupingEndpoint.authenticate

protocol SignInLogicControllerProtocol {
    func signIn(email: String, password: String, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, CampsGroupingAPIError>) -> Void)
}

class SignInLogicController: SignInLogicControllerProtocol {
    let communicator: SignInCommunicatorProtocol

    init(communicator: SignInCommunicatorProtocol = SignInCommunicator()) {
        self.communicator = communicator
    }

    func signIn(email: String, password: String, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, CampsGroupingAPIError>) -> Void) {
        let body = AuthenticationRequestBody(username: email, password: password)

        communicator.signIn(body: body, scope: scope) { result in
            switch result {
            case .success(let account):
                completion(.success(account))
            case .failure(let error):
                if let decodingError = error as? DecodingError {
                    completion(
                        .failure(.decodingError(decodingError, endpoint))
                    )
                } else {
                    completion(
                        .failure(.fromNSError(error as NSError, endpoint: endpoint))
                    )
                }
            }
        }
    }
}
