import Foundation

struct CampAccessAccount: Equatable, HashID, Codable {
    let accountId: String
    let firstName: String
    let lastName: String
    let email: String
    let accountNumber: Int
    let accessKey: String
    let isUser: Bool
    let avatarUrl: String
    let isBrushfireStaff: Bool

    enum CodingKeys: String, CodingKey {
        case accountId = "Id"
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
