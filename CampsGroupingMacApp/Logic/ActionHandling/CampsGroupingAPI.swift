import Foundation

protocol CampsGroupingEndpointProtocol: Equatable, Hashable {
    var path: String { get }
    var domain: String { get }
    var url: URL { get }
    var method: RequestMethod { get }
}

extension CampsGroupingEndpointProtocol {
    var site: String { "https://api.brushfire.com/" }
    var url: URL { URL(string: path)! }
}

enum CampsGroupingEndpoint: CampsGroupingEndpointProtocol {
    case authenticate
    case getCamps(accessKey: String)

    var path: String {
        switch self {
        case .authenticate:
            "\(site)accounts/auth"
        case .getCamps(let accessKey):
            "\(site)events?accessKey=\(accessKey)&inactive=false&archive=false"
        }
    }

    var domain: String {
        switch self {
        case .authenticate:
            "\(site)accounts/auth"
        case .getCamps:
            "\(site)events"
        }
    }

    var method: RequestMethod {
        switch self {
        case .authenticate: .POST
        case .getCamps: .GET
        }
    }
}

enum RequestMethod: String {
    case GET, POST
}

extension URLRequest {
    init(endpoint: CampsGroupingEndpoint, scope: CampsScope, accessKey: String? = nil) {
        self.init(url: endpoint.url)
        setMethod(endpoint.method)
        var headers: [String: String] = Self.defaultHeaders(token: scope.token)
        if let accessKey = accessKey {
            headers["ACCESS-KEY"] = accessKey
        }
        setHeaders(headers)
    }

    private static func defaultHeaders(token: String) -> [String : String] {
        [
            "Authorization":"Basic \(token)",
            "Api-Version":"2024-02-27",
            "Content-Type":"application/json",
            "Accept":"*/*",
//            "ApplicationToken":"QmFzZWNhbXAgSGVhZHF1YXJ0ZXJz", <-- for Azure app
            "Connection":"keep-alive",
            "Accept-Encoding":"gzip, deflate, br"
        ]
    }

    mutating func setMethod(_ method: RequestMethod) {
        httpMethod = method.rawValue
    }

    mutating func setHeaders(_ headers: [String: String]) {
        headers.forEach { key, value in
            setValue(value, forHTTPHeaderField: key)
        }
    }
}
