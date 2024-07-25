import Foundation
import SwiftCSV

extension GrouperEvent {
    enum APIEvent: Equatable {
        case didRespondToSignIn(
            result: Result<CampAccessAccount, CampsGroupingAPIError>,
            scope: CampsScope,
            fetchID: UUID
        )
        case didRespondToGetCamps(
            result: Result<[Camp], CampsGroupingAPIError>,
            account: CampAccessAccount,
            scope: CampsScope,
            fetchID: UUID
        )
        case didRespondToGetReport(
            result: Result<Report, CampsGroupingAPIError>,
            camp: Camp,
            scope: CampsScope,
            fetchID: UUID
        )
    }
}

extension CSV: Equatable {
    public static func == (lhs: SwiftCSV.CSV<DataView>, rhs: SwiftCSV.CSV<DataView>) -> Bool {
        lhs.columns.debugDescription == rhs.columns.debugDescription && lhs.rows.debugDescription == rhs.rows.debugDescription
    }
}
