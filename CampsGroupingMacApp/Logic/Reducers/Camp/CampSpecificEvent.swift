import Foundation

extension GrouperEvent {
    enum CampSpecificEvent: Equatable {
        case didGetReportForCamp(
            report: Report,
            camp: CampInfo,
            scope: CampsScope
        )

        case didSelectManageReport(
            camp: CampInfo,
            scope: CampsScope
        )

        case didSelectViewGrouping(
            camp: CampInfo,
            scope: CampsScope,
            fetchID: UUID = UUID()
        )

        case didSelectFieldTypeButtonForField(ReportFieldSetting)
        case didChangeField(ReportFieldSetting)
        case didUpdateReport(Report)

        case didSelectBeginGrouping(campers: [CamperRow], camp: CampInfo, scope: CampsScope)

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
