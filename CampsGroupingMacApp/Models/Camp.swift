import Foundation

struct Camp: Equatable, Hashable {
    let info: CampInfo
    var report: Report?
    var campSettings: CampSettings?
    var changes: [CampChange]

    init(
        info: CampInfo,
        report: Report? = nil,
        campSettings: CampSettings? = nil,
        changes: [CampChange] = []
    ) {
        self.info = info
        self.report = report
        self.campSettings = campSettings
        self.changes = changes
    }

    var campers: [Camper] {
        guard
            let campSettings = self.campSettings,
            let report = self.report
        else { return [] }
        let settings = campSettings.withChanges(changes)

        return report.csv.rows.compactMap { row in
            Camper(row: row, settings: settings)
        }
    }

    var pendingChanges: [CampChange] {
        changes.pendingChanges(toSettings: campSettings)
    }

    var withChangesApplied: Camp {
        var camp = self
        camp.campSettings = campSettings?.withChanges(changes)
        camp.changes = []
        return camp
    }
}

enum CampChange: Equatable, Hashable {
    case formatChange(ReportFieldSetting)
    case camperChange(CamperSetting)
}

struct CamperSetting: Equatable, Codable, Hashable {
    let id: Int
    var currentGroupID: Int?
    var associatedCamperIDs: [Int]
    var exceptionsHandled: Bool
}

struct CampSettings: Equatable, Codable, Hashable {
    var report: ReportFormat
    var campers: [CamperSetting]

    func withChanges(_ changes: [CampChange]) -> CampSettings {
        var settings = self
        for change in changes.pendingChanges(toSettings: self) {
            switch change {
            case .formatChange(let reportFieldSetting):
                settings.report = settings.report.formatWithSetting(reportFieldSetting)
            case .camperChange(let camperSetting):
                settings.campers = campers.arrayWithSetting(camperSetting)
            }
        }
        return settings
    }
}

extension Array where Element == CampChange {
    func camperChanges(forSettings settings: CampSettings?) -> [CampChange] {
        camperChanges.filter { setting in
            !(settings?.campers ?? [])
                .contains { camper in
                    camper == setting
            }
        }
        .sortedByID
        .map {
            .camperChange($0)
        }
    }

    func reportChanges(forSettings settings: CampSettings?) -> [CampChange] {
        reportChanges.filter { setting in
            !(settings?.report.reportFieldSettings ?? [])
                .contains { fieldSetting in
                    fieldSetting == setting
            }
        }
        .sortedByFieldName
        .map {
            .formatChange($0)
        }
    }

    func pendingChanges(toSettings settings: CampSettings?) -> [CampChange] {
        var changes = camperChanges(forSettings: settings)
        changes.append(contentsOf: reportChanges(forSettings: settings))
        return changes
    }

    var reportChanges: [ReportFieldSetting] {
        compactMap {
            if case .formatChange(let setting) = $0 {
                setting
            } else {
                nil
            }
        }
    }

    var camperChanges: [CamperSetting] {
        compactMap {
            if case .camperChange(let setting) = $0 {
                setting
            } else {
                nil
            }
        }
    }
}

extension Array where Element == CamperSetting {
    func arrayWithSetting(_ setting: CamperSetting) -> [CamperSetting] {
        var settings = self.filter { $0.id != setting.id }
        settings.append(setting)
        return settings.sortedByID
    }

    var sortedByID: [CamperSetting] {
        sorted(by: { setting1, setting2 in
            setting1.id < setting2.id
        })
    }
}

extension Array where Element == ReportFieldSetting {
    func arrayWithSetting(_ setting: ReportFieldSetting) -> [ReportFieldSetting] {
        var settings = self.filter { $0.fieldName != setting.fieldName }
        settings.append(setting)
        return settings.sortedByFieldName
    }

    var sortedByFieldName: [ReportFieldSetting] {
        sorted(by: { setting1, setting2 in
            setting1.fieldName < setting2.fieldName
        })
    }
}
