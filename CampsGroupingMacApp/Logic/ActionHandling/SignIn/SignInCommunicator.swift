import Foundation

private let endpoint = CampsGroupingEndpoint.authenticate

protocol SignInCommunicatorProtocol {
    func signIn(body: AuthenticationRequestBody, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, NSError>) -> Void)
}

class SignInCommunicator: SignInCommunicatorProtocol {
    let client: BrushfireClientProtocol

    init(
        client: BrushfireClientProtocol = BrushfireClient()
    ) {
        self.client = client
    }

    func signIn(body: AuthenticationRequestBody, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, NSError>) -> Void) {
        var request = URLRequest(endpoint: endpoint, scope: scope)
        request.httpBody = body.data
        _ = client.networkTask(
            scope: scope,
            call: SigninCall(
                request: request,
                domain: endpoint.domain,
                completion: completion
            )
        )
    }
}

struct SigninCall: BrushfireCall {
    let request: URLRequest
    let domain: String
    let completion: (Result<CampAccessAccount, NSError>) -> Void

    var decodableCall: BrushfireDecodableCall<CampAccessAccount> {
        .init(request: request, domain: domain, completion: completion)
    }
}
