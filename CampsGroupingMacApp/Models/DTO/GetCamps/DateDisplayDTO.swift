import Foundation

struct DateDisplayDTO: Codable {
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

    func translateToModel() -> DateDisplay {
        DateDisplay(
            months: months,
            dates: dates,
            days: days,
            times: times,
            isOngoing: isOngoing
        )
    }
}

extension Collection where Element == DateDisplayDTO {
    func translatedToModels() -> [DateDisplay] {
        compactMap { dto in
            dto.translateToModel()
        }
    }
}
