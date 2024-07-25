import Foundation

struct CampDatesSet: Codable, Equatable, HashID {
    let doorsAt: Date?
    let startsAt: Date?
    let endsAt: Date?
}
