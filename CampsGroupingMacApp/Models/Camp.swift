import Foundation

struct Camp: Equatable {
    let info: CampInfo
    let report: Report?
    let campSettings: CampSettings?
    var changes: [CampChange]

    init(
        info: CampInfo,
        report: Report?,
        campSettings: CampSettings?,
        changes: [CampChange] = []
    ) {
        self.info = info
        self.report = report
        self.campSettings = campSettings
        self.changes = changes
    }

    func updated(withReport: Report) -> Camp {
        
    }

    func updated(withSettings: CampSettings) -> Camp {

    }

    func campers() -> [Camper] {
        guard 
            let campSettings = self.campSettings,
            let report = self.report
        else { return [] }

        return report.csv.rows.compactMap { row in
            Camper(row: row, settings: campSettings)
        }
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
    let report: ReportFormat
    let campers: [CamperSetting]

    func withChanges(_ changes: [CampChange]) -> CampSettings {
        
    }
}

extension Array where Element == CampChange {
    func camperChanges(forSettings settings: CampSettings?) -> [CampChange] {
        camperChanges.filter { setting in
            !(settings?.campers ?? [])
                .contains { camper in
                    camper.
            }
        }
        .map {
            .camperChange($0)
        }
    }

    func reportChanges(forSettings settings: CampSettings?) -> [CampChange] {

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
