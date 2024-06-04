import Foundation

struct CampAccessAccount: Equatable, Identifiable, Hashable, Codable {
    let scope: CampsScope
    let account: CampAccessAccountInfo

    var id: String {
        scope.rawValue
    }
}

enum CampsScope: String, Equatable, Identifiable, Hashable, Codable {
    case camps = "CAMPS"
    case manCamp = "MANCAMP"
    case sandbox = "SANDBOX"

    var id: String {
        rawValue
    }
}

struct CampAccessAccountInfo: Equatable, Identifiable, Hashable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let accountNumber: String
    let accessKey: String
    let isUser: Bool
    let avatarUrl: String
    let isBrushfireStaff: Bool

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case firstName = "FirstName"
        case lastName = "LastName"
        case email = "Email"
        case accountNumber = "AccountNumber"
        case accessKey = "AccessKey"
        case isUser = "IsUser"
        case avatarUrl = "AvatarUrl"
        case isBrushfireStaff = "IsBrushfireStaff"
    }
}

// MARK: - Response only Objects

struct AuthenticationResponse: Equatable, Hashable, Codable {
    let data: AuthenticationData
    let metaData: AuthenticationMetaData
}

struct AuthenticationData: Equatable, Hashable, Codable {
    let accounts: [CampAccessAccount]
}

struct AuthenticationMetaData: Equatable, Hashable, Codable {
    let author: String
}

// MARK: Authentication Request Data

struct AuthenticationRequestBody: Codable {
    let username: String
    let password: String

    var data: Data {
        (try? JSONEncoder.shared.encode(self)) ?? Data()
    }
}

extension JSONEncoder {
    static let shared: JSONEncoder = JSONEncoder()
}
