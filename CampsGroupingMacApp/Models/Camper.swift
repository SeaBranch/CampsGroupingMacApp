//
//  Camper.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/24/24.
//

import Foundation

struct Camper: Equatable, Identifiable, Hashable {
    let id: Int
    let attendeeID: String
    let name: String
    var currentGroup: GroupIdentification?
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
        guard let camperID = fieldValues.camperNumber,
              let camperName = fieldValues.camperName,
              let attendeeID = fieldValues.attendeeID
        else {
            return nil
        }

        let match = settings.campers.first(where: { $0.camperID == camperID })

        id = camperID
        self.attendeeID = attendeeID
        name = camperName
        
        currentGroup = match?.group
        ?? fieldValues.currentGroup
        
        groupSettingStatus = match?.status ?? ((fieldValues.currentGroupNumber != nil) ? .uploaded : nil)
        associatedCamperIDs = settings.campers
            .first { $0.camperID == camperID }?
            .associatedCampers ?? []
        requiresDirectHandling = values.requiresDirectHandling(
            accordingToSettings: settings
        )
    }
}

extension Dictionary where Key == String, Value == ReportFieldValue {
    var camperNumber: Int? {
        var id: Int?
        values.forEach {
            if case .camperNumber(let value, _, _, true) = $0 {
                id = value
            }
        }
        return id
    }

    var attendeeID: String? {
        var id: String?
        values.forEach {
            if case .camperID(let value, _, true) = $0 {
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

    var currentGroup: GroupIdentification? {
        if let gID = currentGroupID, let gNum = currentGroupNumber {
            return GroupIdentification(
                groupNumber: gNum,
                groupId: gID
            )
        } else {
            return nil
        }
    }

    var currentGroupNumber: Int? {
        var group: Int?

        values.forEach {
            if case .groupNumber(let value, _, _, true) = $0 {
                group = value
            }
        }

        return group
    }

    var currentGroupID: String? {
        var group: String?

        values.forEach {
            if case .groupID(let value, _, true) = $0 {
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
