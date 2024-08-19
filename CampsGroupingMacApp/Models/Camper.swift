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
    var groupSettingStatus: CamperAssignmentStatus?
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
        
        let match = settings.campers.first(where: { $0.camperID == camperID })

        id = camperID
        name = camperName
        currentGroupID = match?.groupID ?? fieldValues.currentGroupID
        groupSettingStatus = match?.status ?? ((fieldValues.currentGroupID != nil) ? .uploaded : nil)
        associatedCamperIDs = settings.campers
            .first { $0.camperID == camperID }?
            .associatedCampers ?? []
        requiresDirectHandling = values.requiresDirectHandling(
            accordingToSettings: settings
        )
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

    var email: String? {
        var emailString: String?

        values.forEach {
            if case .email(let rawValue, _, true) = $0 {
                emailString = rawValue
            }
        }

        return emailString
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
