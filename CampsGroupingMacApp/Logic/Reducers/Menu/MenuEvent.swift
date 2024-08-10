import Foundation

extension GrouperEvent {
    enum MenuEvent: Equatable {
        case didSignOut
        case didSelectCamp(camp: Camp, scope: CampsScope)
        case didGoBackToCamps(scope: CampsScope)
    }
}
