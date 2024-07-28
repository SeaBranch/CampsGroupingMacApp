import Foundation

extension GrouperEvent {
    enum CampSpecificEvent: Equatable {
        case didGetReportForCamp(
            report: Report,
            camp: Camp,
            scope: CampsScope
        )

        case didSelectManageReport(
            camp: Camp,
            scope: CampsScope
        )

        case didSelectViewGrouping(
            camp: Camp,
            scope: CampsScope,
            fetchID: UUID = UUID()
        )

        case didSelectFieldTypeButtonForField(ReportField)
        case didChangeField(ReportField)
        case didUpdateReport(Report)

        case didSelectBeginGrouping(campers: [CamperRow], camp: Camp, scope: CampsScope)

        case didSelectCamperRow(camper: Camper, inSection: GroupingSection)
        case didSelectFilterOptions(inSection: GroupingSection)
        case didSelectGroupRow(groupID: Int, inSection: GroupingSection)
        case didSelectCompareMode(GroupingCompareMode)
        case didChangeFilterOptions(options: [ReportFieldType])
    }
}

enum GroupingSection {
    case camper, compare, detail
}

enum GroupingCompareMode {
    case groups, campers
}
