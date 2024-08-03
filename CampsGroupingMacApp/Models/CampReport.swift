import Foundation
import SwiftCSV

struct ReportFormat: Equatable, Codable, Hashable {
    let reportID: String
    let campEventNumber: Int
    let campScope: CampsScope
    let reportFieldSettings: [ReportFieldSetting]

    var reportEndpoint: URL {
        URL(string: "https://app.brushfire.com/r/\(reportID)/export")!
    }

    func getReport(result: @escaping (Result<Report, NSError>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                if let csv = try? CSV<Named>(url: reportEndpoint) {
                    let report  = Report(csv: csv, campID: campEventNumber)
                    DispatchQueue.main.async {
                        result(.success(report))
                    }
                } else {
                    throw NSError(domain: "https://app.brushfire.com/r", code: 404)
                }
            } catch {
                let nsError = error as NSError
                DispatchQueue.main.async {
                    result(.failure(nsError))
                }
            }
        }
    }
}

enum TestReportID: String, CaseIterable {
    case fatherSonDemo = "https://app.brushfire.com/r/b2abb5b6-4e02-434e-b897-ccb18fce25aa/export"

    func getReport(result: @escaping (Result<Report, NSError>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                if let csv = try? CSV<Named>(url: URL(string: self.rawValue)!) {
                    let report  = Report(csv: csv, campID: campID)
                    DispatchQueue.main.async {
                        result(.success(report))
                    }
                } else {
                    throw NSError(domain: "csv", code: 404)
                }
            } catch {
                let nsError = error as NSError
                DispatchQueue.main.async {
                    result(.failure(nsError))
                }
            }
        }
    }

    var campID: Int {
        switch self {
        case .fatherSonDemo: 573184
        }
    }

    var scope: CampsScope {
        switch self {
        case .fatherSonDemo: .sandbox
        }
    }

    static func forCamp(_ camp: CampInfo) -> TestReportID? {
        Self.allCases.first { reportID in
            reportID.campID == camp.eventNumber
        }
    }
}

typealias ReportRow = [String: String]

struct Report: Equatable {
    let csv: CSV<Named>
    let campID: Int

    var rowCount: Int {
        csv.rows.count
    }

    init(csv: CSV<Named>, campID: Int) {
        self.csv = csv
        self.campID = campID
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

    func value(for rawValue: String?) -> ReportFieldValue {
        if let string = rawValue {
            switch fieldType {
            case .string: 
                    .string(rawValue: string, fieldName: fieldName)
            case .fullName: 
                    .fullName(rawValue: string, fieldName: fieldName)
            case .partOfName: 
                    .partOfName(rawValue: string, fieldName: fieldName)
            case .int: 
                    .int(value: Int(string), rawValue: string, fieldName: fieldName)
            case .bool: 
                    .bool(value: Bool(string), rawValue: string, fieldName: fieldName)
            case .zip: 
                    .zip(value: ZipLocation.fromZipString(string), rawValue: string, fieldName: fieldName)
            case .camperID: 
                    .camperID(value: Int(string), rawValue: string, fieldName: fieldName)
            case .groupID: 
                    .groupID(value: Int(string), rawValue: string, fieldName: fieldName)
            case .crossroadsSite: 
                    .crossroadsSite(rawValue: string, fieldName: fieldName)
            default: 
                    .empty(fieldName: fieldName)
            }
        } else {
            .empty(fieldName: fieldName)
        }
    }
}

enum ReportFieldValue: Equatable, Hashable {
    case string(rawValue: String, fieldName: String)
    case fullName(rawValue: String, fieldName: String)
    case partOfName(rawValue: String, fieldName: String)
    case int(value: Int?, rawValue: String, fieldName: String)
    case bool(value: Bool?, rawValue: String, fieldName: String)
    case zip(value: ZipLocation?, rawValue: String, fieldName: String)
    case camperID(value: Int?, rawValue: String, fieldName: String)
    case groupID(value: Int?, rawValue: String, fieldName: String)
    case crossroadsSite(rawValue: String, fieldName: String)
    case empty(fieldName: String)

    func difference(from other: ReportFieldValue, with equivalance: Double) -> Double? {
        switch self {
        case .string(let stringL, _):
            if case .string(let stringR, _) = other {
                return (stringL == stringR ? 0 : 1) * equivalance
            }

        case .crossroadsSite(let stringL, _):
            if case .crossroadsSite(let stringR, _) = other {
                return (stringL == stringR ? 0 : 1) * equivalance
            }

        case .int(let intL, _, _):
            if case .int(let intR, _, _) = other,
               let ourInt = intL,
               let otherInt = intR
            {
                return Double(abs(ourInt - otherInt)) * equivalance
            }

        case .bool(let bool, _, _):
            if case .bool(let otherBool, _, _) = other,
               let bool = bool,
               let otherBool = otherBool {
                return (bool == otherBool ? 0 : 1) * equivalance
            }

        case .zip(let zipLocation, _, _):
            if case .zip(let otherZip, _, _) = other,
               let location = zipLocation?.location,
               let otherLocation = otherZip?.location {
                return location.distance(from: otherLocation) * equivalance
            }

        default:
            return nil
        }

        return nil
    }

    var rawValue: String {
        switch self {
        case .string(let string, _):            string
        case .fullName(let string, _):          string
        case .partOfName(let string, _):        string
        case .int(_, let string, _):            string
        case .bool(_, let string, _):           string
        case .zip(_, let string, _):            string
        case .camperID(_, let string, _):       string
        case .groupID(_, let string, _):        string
        case .crossroadsSite(let string, _):    string
        case .empty:                            ""
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
         camperID,
         groupID,
         crossroadsSite,
         empty
}
