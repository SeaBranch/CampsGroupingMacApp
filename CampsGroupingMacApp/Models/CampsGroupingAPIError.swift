import Foundation

enum CampsGroupingAPIError: Error, Equatable, HashID, Sendable {
    case badAuthentication(NSError, CampsGroupingEndpoint)
    case noAccess(NSError, CampsGroupingEndpoint)
    case notFound(NSError, CampsGroupingEndpoint)
    case forbidden(NSError, CampsGroupingEndpoint)
    case tooManyRequests(NSError, CampsGroupingEndpoint)
    case badRequest(NSError, CampsGroupingEndpoint)
    case serviceFailure(NSError, CampsGroupingEndpoint)
    case decodingError(DecodingError, CampsGroupingEndpoint)
    case unknownError(CampsGroupingEndpoint)

    static func fromNSError(_ nsError: NSError?, endpoint: CampsGroupingEndpoint) -> Self {
        guard let nsError = nsError else {
            return .unknownError(endpoint)
        }

        switch nsError.code {
        case 401:
            return .badAuthentication(nsError, endpoint)
        case 403:
            return .forbidden(nsError, endpoint)
        case 429:
            return .tooManyRequests(nsError, endpoint)
        case 404:
            switch endpoint {
            case .authenticate:
                return .noAccess(nsError, endpoint)
            default:
                return .notFound(nsError, endpoint)
            }

        default:
            return .serviceFailure(nsError, endpoint)
        }
    }
}

extension DecodingError: Equatable, Hashable {
    public static func == (lhs: DecodingError, rhs: DecodingError) -> Bool {
        (lhs as NSError).code == (rhs as NSError).code &&
        lhs.failureReason == rhs.failureReason
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self as NSError)
    }
}
