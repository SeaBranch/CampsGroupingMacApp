import Foundation

extension MenuEventReducer {
    enum DidSelectAccessAccountReducer {
        static func handleEvent(
            account: CampAccessAccount,
            fetchID: UUID,
            state: inout GrouperState
        ) -> [GrouperAction] {
            []
        }
    }
}
