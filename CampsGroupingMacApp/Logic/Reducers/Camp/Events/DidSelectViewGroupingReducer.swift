import Foundation

extension CampSpecificEventReducer {
    enum DidSelectViewGroupingReducer {
        static func handleEvent(
            camp: Camp,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            []
        }
    }
}
