import Foundation

extension CampSpecificEventReducer {
    enum DidSelectViewGroupingReducer {
        static func handleEvent(
            camp: CampInfo,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            []
        }
    }
}
