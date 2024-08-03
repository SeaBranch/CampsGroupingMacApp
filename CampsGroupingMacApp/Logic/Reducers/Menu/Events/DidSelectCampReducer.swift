import Foundation

extension MenuEventReducer {
    enum DidSelectCampReducer {
        static func handleEvent(
            camp: CampInfo,
            state: inout GrouperState
        ) -> [GrouperAction] {
            []
        }
    }
}
