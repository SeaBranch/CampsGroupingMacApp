import Foundation

extension GrouperEvent {
    enum CampSpecificEvent: Equatable {
        case didSelectManageReport(camp: Camp)
        case didSelectViewGrouping(camp: Camp)
        case reportEvent(event: ReportFormattingEvent)
    }

    enum CamperGroupingEvent: Equatable {
        case didChangeCamperSetting(CamperSetting)
        case didChangeSearchQuery(section: GroupingSection, query: String)
        case didSelectField(field: ReportFieldSetting)
        case didSelectFieldSort(sortOrder: SortOrder)
        case didSetFilterForReportFieldSetting(filterText: String)
        case didSetFilterOptionsForReportFieldSetting(filterOptions: [String])
        case didSelectCamperToGroup(camper: Camper)
        case didToggleCamperRow(camper: Camper, campID: Int)
        case didAskToGroupCampers(campers: [Camper], groupID: Int)
    }

    enum ReportFormattingEvent: Equatable {
        case didChangeReportIdentifier(String)
        case didChangeReportFieldSetting(ReportFieldSetting)
        case didChangeSearchQuery(section: ReportFieldSection, query: String)
    }
}

enum ReportFieldSection {
    case availibleFields, enabledFields
}

enum GroupingSection {
    case camper, compare, detail
}
