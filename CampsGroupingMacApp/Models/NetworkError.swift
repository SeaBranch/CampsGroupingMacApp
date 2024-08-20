import Foundation

enum NetworkError: Error, Equatable, Hashable {
    case signIn(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case camps(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case groups(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case campReports(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case campReport(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case campReportFormat(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case camperSettings(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case updateCampers(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case setReport(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case updateReportFormat(error: CampsGroupingAPIError, networkCall: NetworkCall)
}
