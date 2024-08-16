import Foundation
import SwiftData

private let endpoint = CampsGroupingEndpoint.authenticate

protocol SignInLogicControllerProtocol {
    func signIn(email: String, password: String, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, CampsGroupingAPIError>) -> Void)
}

class SignInLogicController: SignInLogicControllerProtocol {
    let modelContainer: ModelContainer
    let communicator: SignInCommunicatorProtocol

    init(
        modelContainer: ModelContainer,
        communicator: SignInCommunicatorProtocol = SignInCommunicator()
    ) {
        self.modelContainer = modelContainer
        self.communicator = communicator
    }

    @MainActor
    func signIn(email: String, password: String, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, CampsGroupingAPIError>) -> Void) {
        let login = try? modelContainer.mainContext.fetch(FetchDescriptor<AppLogin>())
        if let currentLogin = login?.first {
            if Date().timeIntervalSince(currentLogin.dateCreated) <= TimeInterval(24 * 60 * 60), currentLogin.email == email, scope == currentLogin.scope {
                completion(.success(currentLogin.account))
            } else {
                modelContainer.mainContext.delete(currentLogin)
                fetchAuth(email: email, password: password, scope: scope, completion: completion)
            }
        } else {
            fetchAuth(email: email, password: password, scope: scope, completion: completion)
        }
    }

    @MainActor
    func fetchAuth(email: String, password: String, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, CampsGroupingAPIError>) -> Void) {
        let body = AuthenticationRequestBody(username: email, password: password)
        
        communicator.signIn(body: body, scope: scope) { result in
            switch result {
            case .success(let account):
                self.modelContainer.mainContext.insert(AppLogin.fromAccount(account, scope: scope))
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
