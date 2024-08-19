//
//  GetCampsCommunicator.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/26/24.
//

import Foundation

protocol GetCampsCommunicatorProtocol {
    func getCamps(
        accessKey: String,
        scope: CampsScope,
        completion: @escaping (Result<[CampInfo], NSError>) -> Void
    )
}

class GetCampsCommunicator: GetCampsCommunicatorProtocol {
    let client: BrushfireClientProtocol

    init(
        client: BrushfireClientProtocol = BrushfireClient()
    ) {
        self.client = client
    }

    func getCamps(
        accessKey: String,
        scope: CampsScope,
        completion: @escaping (Result<[CampInfo], NSError>) -> Void
    ) {
        let endpoint = CampsGroupingEndpoint.getCamps(accessKey: accessKey)

        var request = URLRequest(
            endpoint: endpoint,
            scope: scope
        )

        _ = client.networkTask(
            scope: scope,
            call: CampsCall(
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
//
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                let httpResponse = response as? HTTPURLResponse
//                let code = httpResponse?.statusCode ?? 503
//                completion(.failure(NSError(domain: endpoint.domain, code: code)))
//
//                return
//            }
//
//            do {
//                if let data = data {
//                    let responseObject = try JSONDecoder().decode([CampInfo].self, from: data)
//                    completion(.success(responseObject))
//                } else {
//                    completion(.failure(NSError(domain: endpoint.domain, code: 404)))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
    }
}
