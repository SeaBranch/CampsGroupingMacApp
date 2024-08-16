import Foundation

enum MenuEventReducer {
    static func handle(
        event: MenuEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .didSignOut:
            return DidSignOutReducer.handleEvent(state: &state)
        case .didSelectCamp(let camp, let scope):
            return DidSelectCampReducer.handleEvent(
                camp: camp,
                scope: scope,
                state: &state
            )
        case .didGoBackToCamps(let scope):
            state.campScope = scope
            state.navigationMode = .camps
            return []
        case .didSelectSave(let mode):
            switch mode {
            case .report:
                return saveReportFormat(state: &state)
            case .grouping:
                return saveCamperAssignments(state: &state)
            default:
                return []
            }
        }
    }

    static func saveReportFormat(state: inout GrouperState) -> [GrouperAction] {
        guard let camp = state.camp,
              let settings = camp.campSettings?.withChanges(camp.changes),
              let user = state.accessAccount?.accountNumber
        else { return [] }

        let fieldsToUpdate = state.currentFields.filter { setting in
            if let existingRecord = state.camp?.campSettings?.reportSettingsOnRecord.first(where: { record in
                record.fieldName == setting.fieldName
            }) {
                return setting != existingRecord
            } else {
                return !setting.isDefault
            }
        }

        if fieldsToUpdate.isEmpty { return [] }

        return [
            state.beginUpdateReportFormatForCamp(
                campSettings: settings,
                settingsToUpdate: fieldsToUpdate,
                userID: user
            )
        ]
    }

    static func saveCamperAssignments(state: inout GrouperState) -> [GrouperAction] {
        []
    }
}
