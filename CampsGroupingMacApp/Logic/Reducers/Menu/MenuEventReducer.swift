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
        }
    }
}
