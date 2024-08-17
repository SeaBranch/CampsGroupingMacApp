import Foundation

enum NetworkCall: Equatable, Hashable {
    case signIn(UUID = UUID())
    case camps(UUID = UUID())
    case campReports(UUID = UUID())
    case campReport(UUID = UUID())
    case campReportFormat(UUID = UUID())
    case camperSettings(UUID = UUID())
    case setReport(UUID = UUID())
    case updateReportFormat(UUID = UUID())
    case setCamperAssigments(UUID = UUID())
}
