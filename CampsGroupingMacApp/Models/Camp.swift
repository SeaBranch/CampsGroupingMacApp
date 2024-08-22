import Foundation

struct Camp: Equatable, Hashable {
    let info: CampInfo
    let scope: CampsScope
    var report: Report?
    var campSettings: CampSettings?
    var changes: [CampChange]
    var groupsRecord: [CampGroupDTO]
    var equivelencies: [String: Double]

    init(
        info: CampInfo,
        scope: CampsScope,
        report: Report? = nil,
        campSettings: CampSettings? = nil,
        changes: [CampChange] = [],
        equivelencies: [String: Double] = [:],
        groupsRecord: [CampGroupDTO]
    ) {
        self.info = info
        self.scope = scope
        self.report = report
        self.campSettings = campSettings
        self.changes = changes
        self.equivelencies = equivelencies
        self.groupsRecord = groupsRecord
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

    var groups: [CampGroup] {
        groups(withGroupingFields: groupingFields, andEquivelencies: equivelencies)
    }

    func group(withID groupID: GroupIdentification) -> CampGroup? {
        groups.first { group in
            group.groupID == groupID
        }
    }

    var currentFields: [ReportFieldSetting] {
        let campSettings = campSettings?.withChanges(changes)
        var settings = campSettings?.report.reportFieldSettings ?? []
        let setFields = settings.map { $0.fieldName }
        let reportColumns = report?.csv.columns ?? [:]
        let keys = reportColumns.keys.map { $0 }
        for key in keys {
            if !setFields.contains(key) {
                settings.append(ReportFieldSetting(fieldName: key))
            }
        }
        return settings
    }

    var groupingFields: [String] {
        currentFields.filter {
            $0.includeInGrouping &&
            !($0.isRegistrantData && $0.fieldType == .fullName)
        }
        .map { $0.fieldName }
    }

    private func groups(
        withGroupingFields fields: [String],
        andEquivelencies equivelencies: [String: Double]
    ) -> [CampGroup] {
        groupsRecord.map { dto in
            CampGroup(
                dto: dto,
                campersArray: campers,
                groupingFields: fields,
                equivelences: equivelencies
            )
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

    func camperNotes(_ camper: Camper) -> String {
        withChangesApplied.campSettings?.campers.first(where: { setting in
            setting.camperID == camper.id
        })?.notes ?? ""
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
            campers: [], 
            reportSettingsOnRecord: []
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
    let camperID: Int
    let attendeeID: String
    let groupNumber: Int?
    let groupID: String?
    let associatedCampers: [Int]
    let status: CamperAssignmentStatus
    let notes: String

    var group: GroupIdentification? {
        guard let groupId = groupID,
              let groupNum = groupNumber 
        else {
            return nil
        }

        return GroupIdentification(
            groupNumber: groupNum,
            groupId: groupId
        )
    }
}

struct CampSettings: Equatable, Codable, Hashable {
    var report: ReportFormat
    var campers: [CamperSetting]

    var reportSettingsOnRecord: [ReportFieldSetting]

    var hasMinimumRequiredSettings: Bool {
        report.hasMinimumRequiredSettings
    }

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

    var camperChanges: [CamperAssigmentDTO] {
        campers.map {
            var associatedCampers = ""
            $0.associatedCampers.forEach { associatedID in
                if associatedCampers.isEmpty {
                    associatedCampers += "\(associatedID)"
                } else {
                    associatedCampers += ",\(associatedID)"
                }
            }
            return CamperAssigmentDTO(
                camperID: "\($0.camperID)",
                attendeeID: $0.attendeeID,
                groupID: $0.groupID ?? "",
                groupNumber: $0.groupNumber ?? 0,
                associatedCampers: associatedCampers,
                status: $0.status.rawValue,
                notes: $0.notes
            )
        }
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
        var settings = self.filter { $0.camperID != setting.camperID }
        settings.append(setting)
        return settings.sortedByID
    }

    var sortedByID: [CamperSetting] {
        sorted(by: { setting1, setting2 in
            setting1.camperID < setting2.camperID
        })
    }

    func applyingChange(_ change: CampChange?) -> [CamperSetting] {
        switch change {
        case .camperChange(let camperSetting):
            var updated = filter { $0.camperID != camperSetting.camperID }
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
