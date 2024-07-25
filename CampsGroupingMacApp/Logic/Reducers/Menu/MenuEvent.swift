import Foundation

extension GrouperEvent {
    enum MenuEvent: Equatable {
        case didSignOut
        case didSelectAccessAccount(
            account: CampAccessAccount,
            fetchID: UUID = UUID()
        )
        case didSelectCamp(camp: Camp)
        case didGoBackToCamps(scope: CampsScope)
    }
}
