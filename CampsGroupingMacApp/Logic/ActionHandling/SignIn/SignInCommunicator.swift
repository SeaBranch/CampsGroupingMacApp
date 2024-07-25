//
//  SignInCommunicator.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/26/24.
//

import Foundation

private let endpoint = CampsGroupingEndpoint.authenticate

protocol SignInCommunicatorProtocol {
    func signIn(body: AuthenticationRequestBody, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, Error>) -> Void)
}

class SignInCommunicator: SignInCommunicatorProtocol {
    let urlSession: URLSession

    init(
        urlSession: URLSession = .shared
    ) {
        self.urlSession = urlSession
    }

    func signIn(body: AuthenticationRequestBody, scope: CampsScope, completion: @escaping (Result<CampAccessAccount, Error>) -> Void) {
        var request = URLRequest(endpoint: endpoint, scope: scope)
        request.httpBody = body.data

        urlSession.dataTask(with: request) { data, response, error in
            if let error = error as? NSError {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                let httpResponse = response as? HTTPURLResponse
                let code = httpResponse?.statusCode ?? 503
                completion(.failure(NSError(domain: endpoint.path, code: code)))

                return
            }

            do {
                if let data = data {
                    let responseObject = try JSONDecoder()
                        .decode(CampAccessAccount.self, from: data)
                    completion(.success(responseObject))
                } else {
                    completion(.failure(NSError(domain: endpoint.path, code: 404)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
