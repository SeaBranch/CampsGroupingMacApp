import Foundation

protocol CampsGroupingEndpointProtocol: Equatable, Hashable {
    var path: String { get }
    var domain: String { get }
    var url: URL { get }
    var method: RequestMethod { get }
}

extension CampsGroupingEndpointProtocol {
    var brushfire: String { "https://api.brushfire.com" }
    var brushfireReport: String { "https://app.brushfire.com/r" }
    var campsGroupingAPI: String { "http://localhost:7071/api" }
    var url: URL { URL(string: path)! }
}

protocol RequestDTO: Codable {
    var data: Data { get }
}

extension RequestDTO {
    var data: Data {
        (try? JSONEncoder.shared.encode(self)) ?? Data()
    }
}

enum CampsGroupingEndpoint: CampsGroupingEndpointProtocol {
    case authenticate
    case getCamps(accessKey: String)
    case getGroups(camp: Camp)
    case getCampReports
    case getReport(campSettings: CampSettings)
    case getReportFormat(campSettings: CampSettings)
    case getCamperSettings(camp: Camp)
    case setReport(reportID: String, camp: Camp)
    case updateReportFormat(campSettings: CampSettings)
    case setCamperAssigments(campSettings: CampSettings, camp: Camp)

    var path: String {
        switch self {
        case .authenticate:
            "\(brushfire)/accounts/auth"
        case .getCamps(let accessKey):
            "\(brushfire)/events?accessKey=\(accessKey)&inactive=false&archive=false"
        case .getGroups(let camp):
            "\(brushfire)/events/\(camp.info.eventNumber)/groups"
        case .getReport(let campSettings):
            "\(brushfireReport)/\(campSettings.report.reportID)/export"
        case .getCampReports, .setReport:
            "\(campsGroupingAPI)/reports"
        case .getReportFormat(let campSettings), .updateReportFormat(let campSettings):
            "\(campsGroupingAPI)/reportFormat/\(campSettings.report.reportID)"
        case .getCamperSettings(let camp), .setCamperAssigments(_, let camp):
            "\(campsGroupingAPI)/groupingPlan/\(camp.info.eventNumber)"
        }
    }

    var domain: String {
        switch self {
        case .authenticate:
            "\(brushfire)/accounts"
        case .getCamps:
            "\(brushfire)/events"
        case .getGroups:
            "\(brushfire)/events/event_number/groups"
        case .getReport:
            brushfireReport
        case .getCampReports, .setReport:
            "\(campsGroupingAPI)/reports"
        case .getReportFormat, .updateReportFormat:
            "\(campsGroupingAPI)/reportFormat"
        case .getCamperSettings, .setCamperAssigments:
            "\(campsGroupingAPI)/campers"
        }
    }

    var method: RequestMethod {
        switch self {
        case .authenticate, .setReport, .updateReportFormat, .setCamperAssigments: .POST
        default: .GET
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
        var headers: [String: String] = Self.defaultBrushfireHeaders(token: scope.token)
        if let accessKey = accessKey {
            headers["ACCESS-KEY"] = accessKey
        }
        setHeaders(headers)
    }

    init(endpoint: CampsGroupingEndpoint) {
        self.init(url: endpoint.url)
        setMethod(endpoint.method)
        var headers: [String: String] = Self.defaultGroupingAPIHeaders()
        setHeaders(headers)
    }

    private static func defaultBrushfireHeaders(token: String) -> [String : String] {
        [
            "Authorization":"Basic \(token)",
            "Api-Version":"2024-02-27",
            "Content-Type":"application/json",
            "Accept":"*/*",
            "Connection":"keep-alive",
            "Accept-Encoding":"gzip, deflate, br"
        ]
    }

    private static func defaultGroupingAPIHeaders() -> [String : String] {
        [
            "Content-Type":"application/json",
            "Accept":"*/*",
            "ApplicationToken":"QmFzZWNhbXAgSGVhZHF1YXJ0ZXJz",
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
