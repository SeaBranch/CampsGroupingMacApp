import Foundation

struct CampInfo: Codable, Equatable, HashID {
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
    let dateDisplay: DateDisplay
    let latitude: CGFloat
    let longitude: CGFloat
    let mapUrl: String
    let promoImageUrl: String
    let categoryId: Int?
    let categoryName: String?
    let spotsRemaining: Int?
    let spotsTaken: Int?
    let showRemaining: Bool
    let remainingText: String
    let verbiage: String
    let dates: [CampDatesDTO]
    let alternateTitle: String?
    let timeZoneId: String?
    let areaName: String?
    let areaKey: String?
    let paymentProfileId: String?
    let acctCode: String?
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

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? DefaultValues.subtitle
        self.urlKey = try container.decodeIfPresent(String.self, forKey: .urlKey) ?? DefaultValues.urlKey
        self.clientKey = try container.decodeIfPresent(String.self, forKey: .clientKey) ?? DefaultValues.clientKey
        self.clientName = try container.decodeIfPresent(String.self, forKey: .clientName) ?? DefaultValues.clientName
        self.culture = try container.decodeIfPresent(String.self, forKey: .culture) ?? DefaultValues.culture
        self.dateInfo = try container.decodeIfPresent(String.self, forKey: .dateInfo) ?? DefaultValues.dateInfo
        self.dateInfoList = try container.decodeIfPresent([String].self, forKey: .dateInfoList) ?? DefaultValues.dateInfoList
        self.soldOut = try container.decodeIfPresent(Bool.self, forKey: .soldOut) ?? DefaultValues.soldOut
        self.isSticky = try container.decodeIfPresent(Bool.self, forKey: .isSticky) ?? DefaultValues.isSticky
        self.eventNumber = try container.decode(Int.self, forKey: .eventNumber)
        self.isAssigned = try container.decodeIfPresent(Bool.self, forKey: .isAssigned) ?? DefaultValues.isAssigned
        self.locationName = try container.decodeIfPresent(String.self, forKey: .locationName) ?? DefaultValues.locationName
        self.sessionCount = try container.decodeIfPresent(Int.self, forKey: .sessionCount) ?? DefaultValues.sessionCount
        self.isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? DefaultValues.isActive
        self.dateDisplay = try container.decodeIfPresent(DateDisplay.self, forKey: .dateDisplay) ?? DefaultValues.dateDisplay
        self.latitude = try container.decodeIfPresent(CGFloat.self, forKey: .latitude) ?? DefaultValues.latitude
        self.longitude = try container.decodeIfPresent(CGFloat.self, forKey: .longitude) ?? DefaultValues.longitude
        self.mapUrl = try container.decodeIfPresent(String.self, forKey: .mapUrl) ?? DefaultValues.mapUrl
        self.promoImageUrl = try container.decodeIfPresent(String.self, forKey: .promoImageUrl) ?? DefaultValues.promoImageUrl
        self.categoryId = try container.decodeIfPresent(Int.self, forKey: .categoryId)
        self.categoryName = try container.decodeIfPresent(String.self, forKey: .categoryName)
        self.spotsRemaining = try container.decodeIfPresent(Int.self, forKey: .spotsRemaining)
        self.spotsTaken = try container.decodeIfPresent(Int.self, forKey: .spotsTaken)
        self.showRemaining = try container.decodeIfPresent(Bool.self, forKey: .showRemaining) ?? DefaultValues.showRemaining
        self.remainingText = try container.decodeIfPresent(String.self, forKey: .remainingText) ?? DefaultValues.remainingText
        self.verbiage = try container.decodeIfPresent(String.self, forKey: .verbiage) ?? DefaultValues.verbiage
        self.dates = try container.decodeIfPresent([CampDatesDTO].self, forKey: .dates) ?? DefaultValues.dates
        self.alternateTitle = try container.decodeIfPresent(String.self, forKey: .alternateTitle)
        self.timeZoneId = try container.decodeIfPresent(String.self, forKey: .timeZoneId)
        self.areaName = try container.decodeIfPresent(String.self, forKey: .areaName)
        self.areaKey = try container.decodeIfPresent(String.self, forKey: .areaKey)
        self.paymentProfileId = try container.decodeIfPresent(String.self, forKey: .paymentProfileId)
        self.acctCode = try container.decodeIfPresent(String.self, forKey: .acctCode)
        self.isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? DefaultValues.isHidden
        self.isFlexPass = try container.decodeIfPresent(Bool.self, forKey: .isFlexPass) ?? DefaultValues.isFlexPass
    }

    init(
        title: String,
        subtitle: String,
        urlKey: String,
        clientKey: String,
        clientName: String,
        culture: String,
        dateInfo: String,
        dateInfoList: [String],
        soldOut: Bool,
        isSticky: Bool,
        eventNumber: Int,
        isAssigned: Bool,
        locationName: String,
        sessionCount: Int,
        isActive: Bool,
        dateDisplay: DateDisplay,
        latitude: CGFloat,
        longitude: CGFloat,
        mapUrl: String,
        promoImageUrl: String,
        categoryId: Int?,
        categoryName: String?,
        spotsRemaining: Int?,
        spotsTaken: Int?,
        showRemaining: Bool,
        remainingText: String,
        verbiage: String,
        dates: [CampDatesDTO],
        alternateTitle: String?,
        timeZoneId: String?,
        areaName: String?,
        areaKey: String?,
        paymentProfileId: String?,
        acctCode: String?,
        isHidden: Bool,
        isFlexPass: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.urlKey = urlKey
        self.clientKey = clientKey
        self.clientName = clientName
        self.culture = culture
        self.dateInfo = dateInfo
        self.dateInfoList = dateInfoList
        self.soldOut = soldOut
        self.isSticky = isSticky
        self.eventNumber = eventNumber
        self.isAssigned = isAssigned
        self.locationName = locationName
        self.sessionCount = sessionCount
        self.isActive = isActive
        self.dateDisplay = dateDisplay
        self.latitude = latitude
        self.longitude = longitude
        self.mapUrl = mapUrl
        self.promoImageUrl = promoImageUrl
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.spotsRemaining = spotsRemaining
        self.spotsTaken = spotsTaken
        self.showRemaining = showRemaining
        self.remainingText = remainingText
        self.verbiage = verbiage
        self.dates = dates
        self.alternateTitle = alternateTitle
        self.timeZoneId = timeZoneId
        self.areaName = areaName
        self.areaKey = areaKey
        self.paymentProfileId = paymentProfileId
        self.acctCode = acctCode
        self.isHidden = isHidden
        self.isFlexPass = isFlexPass
    }
}

extension CampInfo {
    enum DefaultValues {
    static let subtitle: String = ""
    static let urlKey: String = ""
    static let clientKey: String = ""
    static let clientName: String = ""
    static let culture: String = ""
    static let dateInfo: String = ""
    static let dateInfoList: [String] = []
    static let soldOut: Bool = false
    static let isSticky: Bool = false
    static let isAssigned: Bool = false
    static let locationName: String = ""
    static let sessionCount: Int = 0
    static let isActive: Bool = false
    static let dateDisplay: DateDisplay = DateDisplay(months: "", dates: "", days: "", times: "", isOngoing: false)
    static let latitude: CGFloat = 0
    static let longitude: CGFloat = 0
    static let mapUrl: String = ""
    static let promoImageUrl: String = ""
    static let showRemaining: Bool = false
    static let remainingText: String = ""
    static let verbiage: String = ""
    static let dates: [CampDatesDTO] = []
    static let isHidden: Bool = false
    static let isFlexPass: Bool = false
    }
}
