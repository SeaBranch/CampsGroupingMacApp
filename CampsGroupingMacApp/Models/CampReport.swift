import Foundation
import SwiftCSV

struct ReportFormat: Equatable, Codable, Hashable {
    let campEventNumber: Int
    let campScope: CampsScope
    var reportID: String
    var reportFieldSettings: [ReportFieldSetting]

    var hasMinimumRequiredSettings: Bool {
        hasCamperIdSetting &&
        hasCamperNameSetting &&
        hasCamperGroupIdSetting
    }

    var hasCamperNameSetting: Bool {
        reportFieldSettings.contains { setting in
            setting.fieldType == .fullName &&
            setting.isRegistrantData &&
            setting.visable &&
            setting.showInTable
        }
    }

    var hasCamperIdSetting: Bool {
        reportFieldSettings.contains { setting in
            setting.fieldType == .camperID &&
            setting.isRegistrantData &&
            setting.visable
        }
    }

    var hasCamperGroupIdSetting: Bool {
        reportFieldSettings.contains { setting in
            setting.fieldType == .groupID &&
            setting.isRegistrantData &&
            setting.visable
        }
    }

    var hasCamperNumberSetting: Bool {
        reportFieldSettings.contains { setting in
            setting.fieldType == .camperNumber &&
            setting.isRegistrantData &&
            setting.visable
        }
    }

    var hasCamperGroupNumberSetting: Bool {
        reportFieldSettings.contains { setting in
            setting.fieldType == .groupNumber &&
            setting.isRegistrantData &&
            setting.visable &&
            setting.showInTable
        }
    }

    func formatWithSetting(_ setting: ReportFieldSetting) -> ReportFormat {
        var format = self
        format.reportFieldSettings = reportFieldSettings.arrayWithSetting(setting)
        return format
    }
}

struct ReportAddress: Codable, Equatable {
    let campID: String
    let reportID: String
}

typealias ReportRow = [String: String]

struct Report: Equatable, Hashable {
    let csv: CSV<Named>
    let campID: Int

    var rowCount: Int {
        csv.rows.count
    }

    init(csv: CSV<Named>, campID: Int) {
        self.csv = csv
        self.campID = campID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(csv.rows)
        hasher.combine(campID)
    }
}

extension ReportRow {
    func value(forField field: ReportFieldSetting) -> ReportFieldValue? {
        field.value(for: self[field.fieldName])
    }
}

struct ReportFieldSetting: Equatable, Identifiable, Codable, Hashable {
    var id: String {
        fieldName
    }

    let fieldName: String
    var fieldType: ReportFieldType = .string
    var visable: Bool = false
    var showInTable: Bool = false
    var includeInGrouping: Bool = false
    var handleDirectly: Bool = false
    var equivalance: Double = 1
    var differenceIfMissing: Double = 1
    var isRegistrantData: Bool = false

    var isDefault: Bool {
        fieldType == .string &&
        !visable &&
        !showInTable &&
        !includeInGrouping &&
        !handleDirectly &&
        !isRegistrantData
    }

    func value(for rawValue: String?) -> ReportFieldValue {
        if let string = rawValue {
            switch fieldType {
            case .string:
                    .string(
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .email:
                    .email(
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .fullName:
                    .fullName(
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .partOfName:
                    .partOfName(
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .int:
                    .int(
                        value: Int(string),
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .bool:
                    .bool(
                        value: Bool.fromReportString(string), 
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .zip:
                    .zip(
                        value: ZipLocation.fromZipString(string), 
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .camperNumber:
                    .camperNumber(
                        value: Int(string), 
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .groupNumber:
                    .groupNumber(
                        value: Int(string), 
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .camperID:
                    .camperID(rawValue: string, fieldName: fieldName, primary: isRegistrantData)
            case .groupID:
                    .groupID(rawValue: string, fieldName: fieldName, primary: isRegistrantData)
            case .crossroadsSite:
                    .crossroadsSite(
                        rawValue: string, 
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            case .commaSeparatedOptions:
                    .commaSeparatedOptions(
                        values: string.components(separatedBy: string.commaSeparator),
                        rawValue: string,
                        fieldName: fieldName,
                        primary: isRegistrantData
                    )
            default:
                    .empty(fieldName: fieldName)
            }
        } else {
            .empty(fieldName: fieldName)
        }
    }

    func optionsForCampers(_ campers: [Camper]) -> [String] {
        var setOfOptions = Set<String>()
        for camper in campers {
            switch self.fieldType {
            case .string:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .email:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .int:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .bool:
                setOfOptions.insert("True")
                setOfOptions.insert("False")
            case .zip:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .fullName:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .partOfName:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .camperNumber:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .groupNumber:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .crossroadsSite:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .commaSeparatedOptions:
                if case .commaSeparatedOptions(let options, _, _, _) = camper.values[fieldName] {
                    for option in options {
                        setOfOptions.insert(option)
                    }
                }
            case .empty:
                break
            case .camperID:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            case .groupID:
                if let value = camper.values[fieldName] {
                    setOfOptions.insert(value.rawValue)
                }
            }
        }

        return Array(setOfOptions).sorted()
    }
}

extension Bool {
    static func fromReportString(_ reportString: String) -> Bool? {
        switch reportString.lowercased() {
        case "y", "yes", "yup", "yep", "yeah", "uh huh", "true", "t":
            true
        case "n", "no", "nope", "nah", "neh", "uh uh", "nuh uh", "false", "f":
            false
        default:
            Bool(reportString)
        }
    }
}

extension String {
    var sanitized: String {
        self
            .replacingOccurrences(of: "?",                  with: "{questionmark}")
            .replacingOccurrences(of: "#",                  with: "{poundsign}")
            .replacingOccurrences(of: "/",                  with: "{forwardslash}")
            .replacingOccurrences(of: "\\",                 with: "{backwardslash}")
    }

    var desanitized: String {
        self
            .replacingOccurrences(of: "{questionmark}",     with: "?")
            .replacingOccurrences(of: "{poundsign}",        with: "#")
            .replacingOccurrences(of: "{forwardslash}",     with: "/")
            .replacingOccurrences(of: "{backwardslash}",    with: "\\")
    }

    var commaSeparator: String {
        if range(of: ", ") == nil {
            ","
        } else {
            ", "
        }
    }
}

enum ReportFieldValue: Equatable, Hashable {
    case string(rawValue: String, fieldName: String, primary: Bool)
    case email(rawValue: String, fieldName: String, primary: Bool)
    case fullName(rawValue: String, fieldName: String, primary: Bool)
    case partOfName(rawValue: String, fieldName: String, primary: Bool)
    case int(value: Int?, rawValue: String, fieldName: String, primary: Bool)
    case bool(value: Bool?, rawValue: String, fieldName: String, primary: Bool)
    case zip(value: ZipLocation?, rawValue: String, fieldName: String, primary: Bool)
    case camperNumber(value: Int?, rawValue: String, fieldName: String, primary: Bool)
    case groupNumber(value: Int?, rawValue: String, fieldName: String, primary: Bool)
    case camperID(rawValue: String, fieldName: String, primary: Bool)
    case groupID(rawValue: String, fieldName: String, primary: Bool)
    case crossroadsSite(rawValue: String, fieldName: String, primary: Bool)
    case commaSeparatedOptions(values: [String], rawValue: String, fieldName: String, primary: Bool)
    case empty(fieldName: String)

    func difference(from other: ReportFieldValue, with equivalance: Double) -> Double? {
        switch self {
        case .string(let stringL, _, _):
            if case .string(let stringR, _, _) = other {
                return (stringL == stringR ? 0 : 1) * equivalance
            }

        case .email(let stringL, _, _):
            if case .email(let stringR, _, _) = other {
                return (stringL == stringR ? 0 : 1) * equivalance
            }

        case .crossroadsSite(let stringL, _, _):
            if case .crossroadsSite(let stringR, _, _) = other {
                return (stringL == stringR ? 0 : 1) * equivalance
            }

        case .int(let intL, _, _, _):
            if case .int(let intR, _, _, _) = other,
               let ourInt = intL,
               let otherInt = intR
            {
                return Double(abs(ourInt - otherInt)) * equivalance
            }

        case .bool(let bool, _, _, _):
            if case .bool(let otherBool, _, _, _) = other,
               let bool = bool,
               let otherBool = otherBool {
                return (bool == otherBool ? 0 : 1) * equivalance
            }

        case .zip(let zipLocation, _, _, _):
            let metersInAMile: Double = 1609.344
            if case .zip(let otherZip, _, _, _) = other,
               let location = zipLocation?.location,
               let otherLocation = otherZip?.location {
                return (location.distance(from: otherLocation) / metersInAMile) * equivalance
            }
        case .commaSeparatedOptions(let valuesL, _, _, _):
            if case .commaSeparatedOptions(let valuesR, _, _, _) = other, !valuesL.isEmpty {
                var matchesFound = false
                for valueL in valuesL {
                    if valuesR.contains(valueL) {
                        matchesFound = true
                    }
                }

                return matchesFound ? 0 : equivalance
            }

        default:
            return nil
        }

        return nil
    }

    var rawValue: String {
        switch self {
        case .string(let string, _, _):                     string
        case .email(let string, _, _):                      string
        case .fullName(let string, _, _):                   string
        case .partOfName(let string, _, _):                 string
        case .int(_, let string, _, _):                     string
        case .bool(_, let string, _, _):                    string
        case .zip(_, let string, _, _):                     string
        case .camperNumber(_, let string, _, _):            string
        case .groupNumber(_, let string, _, _):             string
        case .crossroadsSite(let string, _, _):             string
        case .commaSeparatedOptions(_, let string, _, _):   string
        case .empty:                                        ""
        case .camperID(let string, _, _):                   string
        case .groupID(let string, _, _):                    string
        }
    }
}

enum ReportFieldType: String, Equatable, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }

    case string,
         int,
         bool,
         zip,
         fullName,
         partOfName,
         camperNumber,
         groupNumber,
         camperID,
         groupID,
         email,
         crossroadsSite,
         commaSeparatedOptions,
         empty

    var displayName: String {
        switch self {
        case .string: "String"
        case .int: "Int"
        case .bool: "Bool"
        case .zip: "Zip"
        case .fullName: "Full Name"
        case .partOfName: "Part of Name"
        case .camperNumber: "Camper Number"
        case .groupNumber: "Group Number"
        case .camperID: "Camper ID"
        case .groupID: "Group ID"
        case .email: "Email"
        case .crossroadsSite: "Crossroads Site"
        case .commaSeparatedOptions: "Comma Separated Options"
        case .empty: "Empty"
        }
    }
}
