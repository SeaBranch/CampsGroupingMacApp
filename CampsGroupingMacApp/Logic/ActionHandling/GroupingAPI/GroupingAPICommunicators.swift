import Foundation

protocol CampGroupingAPIEndpointModel {
    var endpoint: CampsGroupingEndpoint { get }
}

protocol CampGroupingAPIGetEndpointModel: CampGroupingAPIEndpointModel {
    associatedtype D: Codable
}

protocol CampGroupingAPISetEndpointModel: CampGroupingAPIEndpointModel {
    var body: any RequestDTO { get }
}

protocol CampGroupingAPICommunicatorProtocol {
    func get<E: CampGroupingAPIGetEndpointModel>(
        requestData: E,
        completion: @escaping (Result<E.D, NSError>) -> Void
    )

    func set<E: CampGroupingAPISetEndpointModel>(
        requestData: E,
        completion: @escaping (Result<Void, NSError>) -> Void
    )
}

class CampGroupingAPICommunicator: CampGroupingAPICommunicatorProtocol {

    let urlSession: URLSession

    init(
        urlSession: URLSession = .shared
    ) {
        self.urlSession = urlSession
    }

    func get<E: CampGroupingAPIGetEndpointModel>(
        requestData: E,
        completion: @escaping (Result<E.D, NSError>) -> Void
    ) {
        var request = URLRequest(endpoint: requestData.endpoint)
        urlSession.decodableTask(
            request: request,
            domain: requestData.endpoint.domain,
            completion: completion
        )
    }

    func set<E: CampGroupingAPISetEndpointModel>(
        requestData: E,
        completion: @escaping (Result<Void, NSError>) -> Void
    ) {
        var request = URLRequest(endpoint: requestData.endpoint)
        request.httpBody = requestData.body.data
        urlSession.passFailTask(
            request: request,
            domain: requestData.endpoint.domain,
            completion: completion
        )
    }
}

// MARK: URLSession helper extension
extension URLSession {
    func passFailTask(
        request: URLRequest,
        domain: String,
        onResponse: ((URLResponse?) -> Void)? = nil,
        completion: @escaping (Result<Void, NSError>) -> Void
    ) {
        dataTask(with: request) { _, response, error in
            onResponse?(response)
            if let error = error as? NSError {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                let httpResponse = response as? HTTPURLResponse
                let code = httpResponse?.statusCode ?? 503
                completion(.failure(NSError(domain: domain, code: code)))

                return
            }

            completion(.success(Void()))
        }.resume()
    }

    func decodableTask<T: Codable>(
        request: URLRequest,
        domain: String,
        onResponse: ((URLResponse?) -> Void)? = nil,
        completion: @escaping (Result<T, NSError>) -> Void
    ) {
        dataTask(with: request) { data, response, error in
            onResponse?(response)
            if let error = error as? NSError {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                let httpResponse = response as? HTTPURLResponse
                let code = httpResponse?.statusCode ?? 503
                completion(.failure(NSError(domain: domain, code: code)))

                return
            }

            do {
                if let data = data {
                    let responseObject = try JSONDecoder()
                        .decode(T.self, from: data)
                    completion(.success(responseObject))
                } else {
                    completion(.failure(NSError(domain: domain, code: 404)))
                }
            } catch {
                completion(.failure(error as NSError))
            }
        }.resume()
    }
}

