import Foundation

extension MenuEventReducer {
    enum DidSignOutReducer {
        static func handleEvent(
            state: inout GrouperState
        ) -> [GrouperAction] {
            state = GrouperState()
            return []
        }
    }
}
