import Foundation

extension GrouperEvent {
    enum CampSpecificEvent: Equatable {
        case didSelectManageReport(camp: Camp)
        case didSelectViewGrouping(camp: Camp)
        case campersEvent(event: CamperGroupingEvent)
        case reportEvent(event: ReportFormattingEvent)
    }

    enum CamperGroupingEvent: Equatable {
        case didChangeCamperSetting(CamperSetting)
        case didChangeSearchQuery(section: GroupingSection, query: String)
    }

    enum ReportFormattingEvent: Equatable {
        case didChangeReportIdentifier(String)
        case didChangeReportFieldSetting(ReportFieldSetting)
        case didChangeSearchQuery(section: ReportFieldSection, query: String)
    }

    enum CampGroupingEvent: Equatable {
        case didSelectCamperToGroup(camper: Camper)
        case didToggleCamperRow(camper: Camper, campID: Int)
    }
}

enum ReportFieldSection {
    case availibleFields, enabledFields
}

enum GroupingSection {
    case camper, compare, detail
}

//enum GroupingCompareMode {
//    case groups, campers
//}
