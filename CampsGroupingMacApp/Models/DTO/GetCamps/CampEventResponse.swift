import Foundation

struct CampResponse: Codable {
    let event: CampEventDTO
    let hasReport: Bool

    func translateToModel() -> CampInfo {
        CampInfo(
            title: event.title,
            subtitle: event.subtitle,
            urlKey: event.urlKey,
            clientKey: event.clientKey,
            clientName: event.clientName,
            culture: event.culture,
            dateInfo: event.dateInfo,
            dateInfoList: event.dateInfoList,
            soldOut: event.soldOut,
            isSticky: event.isSticky,
            eventNumber: event.eventNumber,
            isAssigned: event.isAssigned,
            locationName: event.locationName,
            sessionCount: event.sessionCount,
            isActive: event.isActive,
            dateDisplay: event.dateDisplay.translateToModel(),
            latitude: event.latitude,
            longitude: event.longitude,
            mapUrl: event.mapUrl,
            promoImageUrl: event.promoImageUrl,
            categoryId: event.categoryId,
            categoryName: event.categoryName,
            spotsRemaining: event.spotsRemaining,
            spotsTaken: event.spotsTaken,
            showRemaining: event.showRemaining,
            remainingText: event.remainingText,
            verbiage: event.verbiage,
            dates: event.dates,
            alternateTitle: event.alternateTitle,
            timeZoneId: event.timeZoneId,
            areaName: event.areaName,
            areaKey: event.areaKey,
            paymentProfileId: event.paymentProfileId,
            acctCode: event.acctCode,
            isHidden: event.isHidden,
            isFlexPass: event.isFlexPass
        )
    }
}

extension Collection where Element == CampResponse {
    func translateToModels() -> [CampInfo] {
        map { $0.translateToModel() }
    }
}
