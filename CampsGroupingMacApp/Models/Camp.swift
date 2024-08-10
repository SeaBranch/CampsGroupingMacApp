import Foundation

struct Camp: Equatable, Hashable {
    let info: CampInfo
    let scope: CampsScope
    var report: Report?
    var campSettings: CampSettings?
    var changes: [CampChange]

    init(
        info: CampInfo,
        scope: CampsScope,
        report: Report? = nil,
        campSettings: CampSettings? = nil,
        changes: [CampChange] = []
    ) {
        self.info = info
        self.scope = scope
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

    mutating func applyChange(_ change: CampChange) {
        changes = changes.pendingChanges(toSettings: campSettings, addingChange: change)
    }

    func withNewReportID(reportID: String) -> Camp {
        var campSettings = self.campSettings
        ?? CampSettings(
            report: ReportFormat(
                campEventNumber: self.info.eventNumber,
                campScope: self.scope,
                reportID: reportID,
                reportFieldSettings: []
            ),
            campers: []
        )

        campSettings.report.reportID = reportID
        var camp = self
        camp.campSettings = campSettings

        return camp
    }
}

enum CampChange: Equatable, Hashable {
    case reportIdChange(String)
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
            case .reportIdChange(let reportID):
                settings.report.reportID = reportID
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
    private func camperChanges(forSettings settings: CampSettings?, addingChange change: CampChange?) -> [CampChange] {
        camperChanges.filter { setting in
            !(settings?.campers ?? [])
                .contains { camper in
                    camper == setting
            }
        }
        .applyingChange(change)
        .sortedByID
        .map {
            .camperChange($0)
        }
    }

    private func reportChanges(forSettings settings: CampSettings?, addingChange change: CampChange?) -> [CampChange] {
        reportChanges.filter { setting in
            !(settings?.report.reportFieldSettings ?? [])
                .contains { fieldSetting in
                    fieldSetting == setting
            }
        }
        .applyingChange(change)
        .sortedByFieldName
        .map {
            .formatChange($0)
        }
    }

    func pendingChanges(toSettings settings: CampSettings?, addingChange change: CampChange? = nil) -> [CampChange] {
        var changes = camperChanges(forSettings: settings, addingChange: change)
        changes.append(contentsOf: reportChanges(forSettings: settings, addingChange: change))
        return changes
    }

    private var reportChanges: [ReportFieldSetting] {
        compactMap {
            if case .formatChange(let setting) = $0 {
                setting
            } else {
                nil
            }
        }
    }

    private var camperChanges: [CamperSetting] {
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

    func applyingChange(_ change: CampChange?) -> [CamperSetting] {
        switch change {
        case .camperChange(let camperSetting):
            var updated = filter { $0.id != camperSetting.id }
            updated.append(camperSetting)
            return updated
        default:
            return self
        }
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

    func applyingChange(_ change: CampChange?) -> [ReportFieldSetting] {
        switch change {
        case .formatChange(let setting):
            var updated = filter { $0.fieldName != setting.fieldName }
            updated.append(setting)
            return updated
        default:
            return self
        }
    }
}

extension Array where Element == Camp {


    mutating func applyChange(_ change: CampChange, toCampNumber campID: Int) -> [Camp] {
        map {
            if $0.info.eventNumber == campID {
                var updated = $0
                updated.applyChange(change)
                return updated
            } else {
                return $0
            }
        }
    }
}
