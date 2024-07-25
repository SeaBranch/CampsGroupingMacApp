import Foundation

struct DateDisplay: Codable, Equatable, HashID {
    let months: String
    let dates: String
    let days: String
    let times: String
    let isOngoing: Bool

    enum CodingKeys: String, CodingKey {
        case months = "Months"
        case dates = "Dates"
        case days = "Days"
        case times = "Times"
        case isOngoing = "IsOngoing"
    }
}
