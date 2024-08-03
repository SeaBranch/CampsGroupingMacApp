import Foundation

protocol CampsGroupingEndpointProtocol: Equatable, Hashable {
    var path: String { get }
    var domain: String { get }
    var url: URL { get }
    var method: RequestMethod { get }
}

extension CampsGroupingEndpointProtocol {
    var brushfire: String { "https://api.brushfire.com/" }
    var campsGroupingAPI: String { "https://api/" }
    var url: URL { URL(string: path)! }
}

enum CampsGroupingEndpoint: CampsGroupingEndpointProtocol {
    case authenticate
    case getCamps(accessKey: String)
    case getCampSettings(camp: Camp)
    case getReport(campSettings: CampSettings)
    case updateCamp(camp: Camp, campSettings: CampSettings, changes: [CampChange])

    var path: String {
        switch self {
        case .authenticate:
            "\(brushfire)accounts/auth"
        case .getCamps(let accessKey):
            "\(brushfire)events?accessKey=\(accessKey)&inactive=false&archive=false"
        case .getCampSettings(let camp):
            "\(campsGroupingAPI)camp/\(camp.info.eventNumber)"
        case .getReport(let campSettings):
            "\(brushfire)r/\(campSettings.report.reportID)/export"
        case .updateCamp(let camp, _, _):
            "\(campsGroupingAPI)camp/\(camp.info.eventNumber)"
        }
    }

    var domain: String {
        switch self {
        case .authenticate:
            "\(brushfire)accounts/auth"
        case .getCamps:
            "\(brushfire)events"
        case .getCampSettings, .updateCamp:
            "\(campsGroupingAPI)camp"
        case .getReport:
            "\(brushfire)/r"
        }
    }

    var method: RequestMethod {
        switch self {
        case .authenticate, .updateCamp: .POST
        case .getCamps, .getCampSettings, .getReport: .GET
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
