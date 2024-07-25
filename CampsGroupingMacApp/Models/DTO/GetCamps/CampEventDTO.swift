import Foundation

struct CampEventDTO: Codable {
        let title: String
        let subtitle: String
        let urlKey: String
        let clientKey: String
        let clientName: String
        let culture: String
        let dateInfo: String
        let dateInfoList: [String]
        let soldOut: Bool
        let isSticky: Bool
        let eventNumber: Int
        let isAssigned: Bool
        let locationName: String
        let sessionCount: Int
        let isActive: Bool
        let dateDisplay: DateDisplayDTO
        let latitude: CGFloat
        let longitude: CGFloat
        let mapUrl: String
        let promoImageUrl: String
        let categoryId: Int
        let categoryName: String
        let spotsRemaining: Int
        let spotsTaken: Int
        let showRemaining: Bool
        let remainingText: String
        let verbiage: String
        let dates: [CampDatesDTO]
        let alternateTitle: String
        let timeZoneId: String
        let areaName: String
        let areaKey: String
        let paymentProfileId: String
        let acctCode: String
        let isHidden: Bool
        let isFlexPass: Bool

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case subtitle = "Subtitle"
        case urlKey = "UrlKey"
        case clientKey = "ClientKey"
        case clientName = "ClientName"
        case culture = "Culture"
        case dateInfo = "DateInfo"
        case dateInfoList = "DateInfoList"
        case soldOut = "SoldOut"
        case isSticky = "IsSticky"
        case eventNumber = "EventNumber"
        case isAssigned = "IsAssigned"
        case locationName = "LocationName"
        case sessionCount = "SessionCount"
        case isActive = "IsActive"
        case dateDisplay = "DateDisplay"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case mapUrl = "MapUrl"
        case promoImageUrl = "PromoImageUrl"
        case categoryId = "CategoryId"
        case categoryName = "CategoryName"
        case spotsRemaining = "SpotsRemaining"
        case spotsTaken = "SpotsTaken"
        case showRemaining = "ShowRemaining"
        case remainingText = "RemainingText"
        case verbiage = "Verbiage"
        case dates = "Dates"
        case alternateTitle = "AlternateTitle"
        case timeZoneId = "TimeZoneId"
        case areaName = "AreaName"
        case areaKey = "AreaKey"
        case paymentProfileId = "PaymentProfileId"
        case acctCode = "AcctCode"
        case isHidden = "IsHidden"
        case isFlexPass = "IsFlexPass"
    }
}
