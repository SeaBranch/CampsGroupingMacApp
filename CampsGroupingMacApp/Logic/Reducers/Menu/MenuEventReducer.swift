import Foundation

enum MenuEventReducer {
    static func handle(
        event: MenuEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .didSignOut:
            return DidSignOutReducer.handleEvent(state: &state)
        case .didSelectAccessAccount(let account, let fetchID):
            return DidSelectAccessAccountReducer.handleEvent(
                account: account,
                fetchID: fetchID,
                state: &state
            )
        case .didSelectCamp(let camp):
            return DidSelectCampReducer.handleEvent(camp: camp, state: &state)
        case .didGoBackToCamps(let scope):
            state.navigationMode = .camps(scope: scope)
            return []
        }
    }
}
