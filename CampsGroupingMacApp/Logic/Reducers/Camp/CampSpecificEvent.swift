import Foundation

extension GrouperEvent {
    enum CampSpecificEvent: Equatable {
        case didSelectManageReport(
            camp: Camp,
            scope: CampsScope
        )

        case didSelectViewGrouping(
            camp: Camp,
            scope: CampsScope,
            fetchID: UUID = UUID()
        )

        case didChangeField(ReportField)
    }
}
