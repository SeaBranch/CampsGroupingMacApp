import Foundation

struct CamperAssignment: Equatable {
    let camper: Camper
    let group: GroupIdentification
}

struct GroupIdentification: Equatable, Hashable, Codable {
    let groupNumber: Int
    let groupId: String
}

struct CamperGroupingState: Equatable {
    var camp: Int
    var camperCurrentlyBeingGrouped: Int?
    var camperSelections: Set<Int> = []
    var pendingAssignments: [CamperAssignment] = []
    var groupingMode: GroupingMode = .manual

    var assigneeFilters: [FilterStep] = []
    var groupMemberFilters: [FilterStep] = []
    var equivelencies: [String: Double] = [:]

    var activeSelection: CamperGroupingFocus?
}

struct CamperGroupingFocus: Equatable {
    let field: ReportFieldSetting
    var sortOrder: SortOrder
    var filter: FieldFilter
}

enum FieldFilter: Equatable {
    case all(field: ReportFieldSetting)
    case exact(expectedValue: String, field: ReportFieldSetting)
    case bool(expectedValue: Bool?, field: ReportFieldSetting)
    case search(query: String, field: ReportFieldSetting)
    case range(from: Int, to: Int, field: ReportFieldSetting)
    case contains(options: [String], field: ReportFieldSetting)

    static func fromString(filterString: String, field: ReportFieldSetting) -> FieldFilter {
        guard !filterString.isEmpty else {
            return .all(field: field)
        }

        if filterString.prefix(1) == "=" {
            return .exact(
                expectedValue: String(filterString.suffix(filterString.count - 1)),
                field: field
            )
        }

        if filterString.prefix(1) == "|" {
            let options = String(filterString.suffix(filterString.count - 1))
                .components(separatedBy: "|")
            return .contains(options: options, field: field)
        }

        switch field.fieldType {
        case .zip, .camperNumber, .groupNumber, .crossroadsSite, .empty:
            return .exact(expectedValue: filterString, field: field)
        case .bool:
            let boolValue = Bool.fromReportString(filterString)
            return .bool(expectedValue: boolValue, field: field)
        default:
            break
        }

        switch field.fieldType {
        case .int:
            let components = filterString
                .components(separatedBy: "-")
                .compactMap { Int($0) }

            if components.count == 2 {
                return .range(
                    from: components[0],
                    to: components[1],
                    field: field
                )
            }
        default:
            return .search(query: filterString, field: field)
        }

        return .search(query: filterString, field: field)
    }
}
//8ad7364d-c715-4134-b889-6021054aeb9c
