import Foundation
import SwiftCSV

extension GrouperEvent {
    enum APIEvent: Equatable {
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
        case didRespondToGetReport(
            result: Result<Report, CampsGroupingAPIError>,
            camp: Camp,
            networkCall: NetworkCall
        )
        case didRespondToGetCampSettings(
            result: Result<CampSettings, CampsGroupingAPIError>,
            camp: Camp,
            networkCall: NetworkCall
        )
        case didRespondToUpdateCampSettings(
            result: Result<CampSettings, CampsGroupingAPIError>,
            camp: Camp,
            networkCall: NetworkCall
        )
    }
}

extension CSV: Equatable {
    public static func == (lhs: SwiftCSV.CSV<DataView>, rhs: SwiftCSV.CSV<DataView>) -> Bool {
        lhs.columns.debugDescription == rhs.columns.debugDescription && lhs.rows.debugDescription == rhs.rows.debugDescription
    }
}
