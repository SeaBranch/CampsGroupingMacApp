//
//  SignInCommunicator.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/26/24.
//

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

//        urlSession.dataTask(with: request) { data, response, error in
//            if let error = error as? NSError {
//                completion(.failure(error))
//                return
//            }
//            let httpResponse = response as? HTTPURLResponse
//            print("headers: [\n\(httpResponse?.allHeaderFields)")
//            print("]")
//
//            guard let httpResponse = httpResponse
//            else {
//                let code = 503
//                completion(.failure(NSError(domain: endpoint.path, code: code)))
//
//                return
//            }
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let nsError = (error as NSError) ?? NSError(domain: endpoint.path, code: code)
//            }
//
//            do {
//                if let data = data {
//                    let responseObject = try JSONDecoder()
//                        .decode(CampAccessAccount.self, from: data)
//                    completion(.success(responseObject))
//                } else {
//                    completion(.failure(NSError(domain: endpoint.path, code: 404)))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
    }
}
