//
//  Camper.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/24/24.
//

import Foundation

struct Camper: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    var currentGroupID: Int?
    var associatedCamperIDs: [Int]
    var requiresDirectHandling: Bool
    var values: [String: ReportFieldValue]

    init?(row: ReportRow, settings: CampSettings) {
        var fieldValues = [String: ReportFieldValue]()
        settings.report.reportFieldSettings.forEach {
            if let value = row.value(forField: $0) {
                fieldValues[$0.fieldName] = value
            }
        }
        values = fieldValues
        guard let camperID = fieldValues.camperID,
              let camperName = fieldValues.camperName
        else {
            return nil
        }
        
        id = camperID
        name = camperName
        associatedCamperIDs = settings.campers.first { $0.id == camperID }?.associatedCamperIDs ?? []
        requiresDirectHandling = values.requiresDirectHandling(accordingToSettings: settings)
    }
}

extension Dictionary where Key == String, Value == ReportFieldValue {
    var camperID: Int? {
        var id: Int?
        values.forEach {
            if case .camperID(let value, _, _, true) = $0 {
                id = value
            }
        }
        return id
    }

    var camperName: String? {
        var name: String?
        values.forEach {
            if case .fullName(let rawValue, _, true) = $0 {
                name = rawValue
            }
        }
        return name
    }

    var currentGroupID: Int? {
        var group: Int?

        values.forEach {
            if case .groupID(let value, _, _, true) = $0 {
                group = value
            }
        }

        return group
    }

    func requiresDirectHandling(
        accordingToSettings settings: CampSettings
    ) -> Bool {
        settings.report.reportFieldSettings.map { setting in
            if setting.handleDirectly, let value = self[setting.fieldName] {
                !value.rawValue.isEmpty
            } else {
                false
            }
        }.contains(true)
    }

    var crossroadsSite: String? {
        var site: String?
        values.forEach {
            if case .crossroadsSite(let rawValue, _ , true) = $0 {
                site = rawValue
            }
        }
        return site
    }
}

//struct CamperRow: Equatable, Identifiable, Hashable {
//    var id: Int { camper.id }
//
//    let camper: Camper
//    let row: ReportRow
//
//    static func arrayFromReportAndData(_ report: Report, campers: [Camper]) -> [CamperRow] {
//        report.rows.compactMap { row in
//            var camperRow: CamperRow?
//            if let camperID = row.camperID, let name = row.fullName {
//                var existingCamper = campers.first { $0.id == camperID }
//
//                var requiresDirectHandling = false
//
//                for field in report.fields where field.handleDirectly {
//                    if !(row[field.fieldName]??.rawValue ?? "").isEmpty {
//                        requiresDirectHandling = true
//                    }
//                }
//
//                existingCamper?.requiresDirectHandling = requiresDirectHandling
//
//                let camper = existingCamper ?? Camper(
//                    id: camperID, 
//                    name: name,
//                    currentGroupID: row.existingGroupID,
//                    associatedCamperIDs: [], // TODO: -> get other campers from existing groups
//                    requiresDirectHandling: requiresDirectHandling
//                )
//
//                camperRow = CamperRow(camper: camper, row: row)
//            }
//
//            return camperRow
//        }
//    }
//}

//extension ReportRow {
//    var camperID: Int? {
//        for value in self.values {
//            if case .camperID(let camperIdInt, _) = value {
//                return camperIdInt
//            }
//        }
//
//        return nil
//    }
//
//    var existingGroupID: Int? {
//        for value in self.values {
//            if case .groupID(let groupIdInt, _) = value {
//                return groupIdInt
//            }
//        }
//
//        return nil
//    }
//
//    var fullName: String? {
//        for value in self.values {
//            if case .fullName(let name) = value {
//                return name
//            }
//        }
//
//        return nil
//    }
//
//    var crossroadsSite: String? {
//        for value in self.values {
//            if case .crossroadsSite(let crossroadsSite) = value {
//                return crossroadsSite
//            }
//        }
//
//        return nil
//    }
//}
