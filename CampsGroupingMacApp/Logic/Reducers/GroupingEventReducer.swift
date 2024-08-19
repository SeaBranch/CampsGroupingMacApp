import Foundation

enum GroupingEventReducer {
    static func handle(
        event: GrouperEvent.CamperGroupingEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        guard let camp = state.camp?.info.eventNumber else { return [] }

        switch event {
        case .didChangeCamperSetting(let camperSetting):
            return didChangeCamperSetting(
                setting: camperSetting,
                state: &state
            )
        case .didChangeSearchQuery(let section, let query):
            return didChangeSearchQuery(section: section, query: query, state: &state)
        case .didSelectCamperToGroup(let camper):
            var gstate = state.groupingState ?? CamperGroupingState(camp: camp)

            gstate.camperCurrentlyBeingGrouped = camper.id

            state.groupingState = gstate

        case .didToggleCamperRow(let camper, let campID):
            var gstate = state.groupingState ?? CamperGroupingState(camp: campID)

            if gstate.camperSelections.contains(camper.id) {
                gstate.camperSelections.remove(camper.id)
            } else {
                gstate.camperSelections.insert(camper.id)
            }

            state.groupingState = gstate
        case .didSelectField(field: let field):
            guard let camp = state.camp else { return [] }
            var gState = state.groupingState ?? CamperGroupingState(camp: camp.info.eventNumber)

            gState.activeSelection = CamperGroupingFocus(
                field: field,
                sortOrder: SortOrder.forward,
                filter: .all(field: field)
            )

            state.groupingState = gState
        case .didSetFilterForReportFieldSetting(let filterText):
            guard let camp = state.camp,
                  var gState = state.groupingState,
                  var selection = gState.activeSelection
            else { return [] }

            selection.filter = FieldFilter.fromString(filterString: filterText, field: selection.field)
            gState.activeSelection = selection
            state.groupingState = gState
        case .didSetFilterOptionsForReportFieldSetting(let filterOptions):
            guard let camp = state.camp,
                  var gState = state.groupingState,
                  var selection = gState.activeSelection
            else { return [] }

            selection.filter = .contains(options: filterOptions, field: selection.field)
            gState.activeSelection = selection
            state.groupingState = gState
        case .didSelectFieldSort(sortOrder: let sortOrder):
            guard let camp = state.camp,
                  var gState = state.groupingState,
                  var selection = gState.activeSelection
            else { return [] }

            selection.sortOrder = sortOrder
            gState.activeSelection = selection
            state.groupingState = gState

        case .didAskToGroupCampers(let campers, let groupID):
            guard let camp = state.camp,
                  let campSettings = camp.campSettings,
                  let userID = state.accessAccount?.accountNumber
            else { return [] }
            let camperChanges = campers.filter({ $0.currentGroupID != groupID }).map { camper in
                CamperSetting(
                    camperID: camper.id,
                    groupID: groupID,
                    associatedCampers: camper.associatedCamperIDs,
                    status: .edited,
                    notes: "directly assigned"
                )
            }

            if camperChanges.isEmpty { return [] }

            return [
                state.beginSetCamperAssigmentsForCamp(
                    camp: camp,
                    campSettings: campSettings,
                    camperChanges: camperChanges,
                    userID: userID
                )
            ]
        }

        return []
    }

    private static func didChangeCamperSetting(
        setting: CamperSetting,
        state: inout GrouperState
    ) -> [GrouperAction] {
        guard let selectedCamp = state.selectedCamp else {
            return []
        }

        let change = CampChange.camperChange(setting)
        state.camps = state.camps.applyChange(change, toCampNumber: selectedCamp)
        return []
    }

    private static func didChangeSearchQuery(
        section: GroupingSection,
        query: String,
        state: inout GrouperState
    ) -> [GrouperAction] {
        []
    }
}
