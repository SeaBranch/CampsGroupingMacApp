import Foundation

extension GrouperEvent {
    enum MenuEvent: Equatable {
        case didSignOut
        case didSelectAccessAccount(
            account: CampAccessAccount,
            fetchID: UUID = UUID()
        )
        case didSelectCamp(camp: CampInfo)
        case didGoBackToCamps(scope: CampsScope)
    }
}
