//
//  SignInLogicController.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Foundation

private enum Constant {
    static var defaultHeaders: [String : String] {
        [
            "Content-Type":"application/json",
            "Accept":"application/json",
            "ApplicationToken":"QmFzZWNhbXAgSGVhZHF1YXJ0ZXJz"
        ]
    }

    static var signInEndpoint = "http://localhost:7071/api/authenticate"
    static var signInURL = URL(string: Constant.signInEndpoint)!
}

protocol SignInLogicControllerProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<[CampAccessAccount], AuthenticationError>) -> Void)
}

class SignInLogicController: SignInLogicControllerProtocol {
    let communicator: SignInCommunicatorProtocol

    init(communicator: SignInCommunicatorProtocol = SignInCommunicator()) {
        self.communicator = communicator
    }

    func signIn(email: String, password: String, completion: @escaping (Result<[CampAccessAccount], AuthenticationError>) -> Void) {
        let body = AuthenticationRequestBody(username: email, password: password)

        communicator.signIn(body: body) { result in
            switch result {
            case .success(let response):
                let accounts = response.data.accounts
                if accounts.isEmpty {
                    completion(.failure(AuthenticationError.noAccess(NSError(domain: Constant.signInEndpoint, code: 404))))
                } else {
                    completion(.success(accounts))
                }
            case .failure(let nsError):
                completion(.failure(AuthenticationError.fromNSError(nsError)))
            }
        }
    }
}

protocol SignInCommunicatorProtocol {
    func signIn(body: AuthenticationRequestBody, completion: @escaping (Result<AuthenticationResponse, NSError>) -> Void)
}

class SignInCommunicator: SignInCommunicatorProtocol {
    let urlSession: URLSession
    let defaultHeaders: [String : String]

    init(
        urlSession: URLSession = .shared,
        defaultHeaders: [String : String] = Constant.defaultHeaders
    ) {
        self.urlSession = urlSession
        self.defaultHeaders = defaultHeaders
    }

    func signIn(body: AuthenticationRequestBody, completion: @escaping (Result<AuthenticationResponse, NSError>) -> Void) {
        var request = URLRequest(url: Constant.signInURL)
        request.httpMethod = "POST"
        defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.httpBody = body.data

        urlSession.dataTask(with: request) { data, response, error in
            if let error = error as? NSError {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let httpResponse = response as? HTTPURLResponse
                let code = httpResponse?.statusCode ?? 503
                completion(.failure(NSError(domain: Constant.signInEndpoint, code: code)))

                return
            }

            if let data = data,
               let responseObject = try? JSONDecoder().decode(AuthenticationResponse.self, from: data) {
                completion(.success(responseObject))
            } else {
                completion(.failure(NSError(domain: Constant.signInEndpoint, code: 404)))
            }
        }.resume()
    }
}
