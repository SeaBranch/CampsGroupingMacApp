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

    init?(row: ReportRow, settings: CampSettings, changes: [CampChange]) {
        for field in settings.report.reportFieldSettings {
            
        }
    }
}

extension Array where Element == ReportFieldSetting {
    var camperID: Int? {
        first { setting in
            switch setting.fieldType {

            }
        }
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
