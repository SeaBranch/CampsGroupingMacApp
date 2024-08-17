import Foundation

struct CamperGroupingState: Equatable {
    var camp: Int
    var camperCurrentlyBeingGrouped: Int?
    var camperSelections: Set<Int> = []

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

    static func fromString(filterString: String, field: ReportFieldSetting) -> FieldFilter {
        guard !filterString.isEmpty else {
            return .all(field: field)
        }

        switch field.fieldType {
        case .zip, .camperID, .groupID, .crossroadsSite, .empty:
            return .exact(expectedValue: filterString, field: field)
        case .bool:
            let boolValue: Bool? = switch filterString.lowercased() {
            case "true", "t": true
            case "false", "f": false
            default: nil
            }

            return .bool(expectedValue: boolValue, field: field)
        default:
            break
        }

        if filterString.prefix(1) == "=" {
            return .exact(
                expectedValue: String(filterString.suffix(filterString.count - 1)),
                field: field
            )
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
