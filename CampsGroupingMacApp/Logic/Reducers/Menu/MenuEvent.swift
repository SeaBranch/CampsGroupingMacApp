import Foundation

extension GrouperEvent {
    enum MenuEvent: Equatable {
        case didSignOut
        case didSelectCamp(camp: CampInfo, scope: CampsScope)
        case didGoBackToCamps(scope: CampsScope)
    }
}
