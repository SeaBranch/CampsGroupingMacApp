import Foundation

extension MenuEventReducer {
    enum DidSelectCampReducer {
        static func handleEvent(
            info: CampInfo,
            scope: CampsScope,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.insert(.campReport(<#T##UUID#>))
            [.getCampReport(info, scope)]
        }
    }
}
