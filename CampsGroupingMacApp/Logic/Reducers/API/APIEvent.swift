import Foundation
import SwiftCSV

extension GrouperEvent {
    enum APIEvent: Equatable {
        case retryNetworkCall(NetworkCall)
        case didRespondToSignIn(
            result: Result<CampAccessAccount, CampsGroupingAPIError>,
            scope: CampsScope,
            networkCall: NetworkCall
        )
        case didRespondToGetCamps(
            result: Result<[CampInfo], CampsGroupingAPIError>,
            account: CampAccessAccount,
            scope: CampsScope,
            networkCall: NetworkCall
        )
        case didRespondToGetGroups(
            result: Result<[CampGroup], CampsGroupingAPIError>,
            account: CampAccessAccount,
            scope: CampsScope,
            networkCall: NetworkCall
        )
        case didRespondToGetCampReports(
            result: GetCampReportsResult,
            requestData: GetCampReportsData,
            networkCall: NetworkCall
        )
        case didRespondToGetReport(
            result: GetReportResult,
            requestData: GetReportData,
            networkCall: NetworkCall
        )
        case didRespondToGetReportFormat(
            result: GetReportFormatResult,
            requestData: GetReportFormatData,
            networkCall: NetworkCall
        )
        case didRespondToGetCamperSettings(
            result: GetCamperSettingsResult,
            requestData: GetCamperSettingsData,
            networkCall: NetworkCall
        )
        case didRespondToSetReport(
            result: SetReportResult,
            requestData: SetReportData,
            networkCall: NetworkCall
        )
        case didRespondToUpdateReportFormat(
            result: UpdateReportFormatResult,
            requestData: UpdateReportFormatData,
            networkCall: NetworkCall
        )
        case didRespondToSetCamperAssigments(
            result: SetCamperAssigmentsResult,
            requestData: UpdateCamperAssigmentsData,
            networkCall: NetworkCall
        )
    }
}

extension CSV: Equatable {
    public static func == (lhs: SwiftCSV.CSV<DataView>, rhs: SwiftCSV.CSV<DataView>) -> Bool {
        lhs.columns.debugDescription == rhs.columns.debugDescription && lhs.rows.debugDescription == rhs.rows.debugDescription
    }
}
