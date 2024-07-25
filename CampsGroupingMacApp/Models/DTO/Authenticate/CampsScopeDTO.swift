import Foundation

enum CampsScopeDTO: String, Equatable, Identifiable, Hashable, Codable {
    case camps = "CAMPS"
    case manCamp = "MANCAMP"
    case sandbox = "SANDBOX"

    var id: String {
        rawValue
    }

    func translateToModel() -> CampsScope {
        switch self {
        case .camps:    .camps
        case .manCamp:  .manCamp
        case .sandbox:  .sandbox
        }
    }
}
