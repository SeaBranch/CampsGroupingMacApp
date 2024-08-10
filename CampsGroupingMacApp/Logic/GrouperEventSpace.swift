//
//  GrouperEventSpace.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 5/30/24.
//

import Foundation

typealias GrouperState = GrouperEventSpace.State
typealias GrouperEvent = GrouperEventSpace.Event
typealias GrouperAction = GrouperEventSpace.Action
typealias APIEvent = GrouperEvent.APIEvent
typealias SignInFormEvent = GrouperEvent.SignInFormEvent
typealias MenuEvent = GrouperEvent.MenuEvent
typealias CampSpecificEvent = GrouperEvent.CampSpecificEvent

enum GrouperEventSpace: EventSpace {
    struct State: Equatable {
        var signInFormState: SignInFormState? = SignInFormState()
        var accessAccount: CampAccessAccount?
        var campScope: CampsScope?

        var activeFetches: Set<NetworkCall> = []
        var errors: Set<NetworkError> = []

        var navigationMode: NavigationMode = .signin
        var camps: [Camp] = []
        var selectedCamp: Int?
    }

    enum Event: Equatable {
        case api(event: APIEvent)
        case signIn(event: SignInFormEvent)
        case menu(event: MenuEvent)
        case camp(event: CampSpecificEvent)
    }

    enum Action {
        case signIn(username: String, password: String, scope: CampsScope, networkCall: NetworkCall)
        case getCamps(account: CampAccessAccount, scope: CampsScope, networkCall: NetworkCall)
        case getReports(networkCall: NetworkCall)
        case getReportForCamp(campSettings: CampSettings, networkCall: NetworkCall)
        case getReportFormatForCamp(campSettings: CampSettings, networkCall: NetworkCall)
        case getCamperSettingsForCamp(camp: Camp, networkCall: NetworkCall)
        case setReportForCamp(reportID: String, camp: Camp, userID: Int, networkCall: NetworkCall)
        case updateReportFormatForCamp(campSettings: CampSettings, userID: Int, networkCall: NetworkCall)
        case setCamperAssigmentsForCamp(camp: Camp, campSettings: CampSettings, userID: Int, networkCall: NetworkCall)
    }

    static func handle(event: Event, state: inout State) -> [Action] {
        switch event {
        case .api(let event):
            APIEventReducer.handle(event: event, state: &state)
        case .signIn(let event):
            SignInFormEventReducer.handle(event: event, state: &state)
        case .menu(let event):
            MenuEventReducer.handle(event: event, state: &state)
        case .camp(let event):
            CampSpecificEventReducer.handle(event: event, state: &state)
        }
    }
}

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

enum NetworkError: Error, Equatable, Hashable {
    case signIn(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case camps(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case campReports(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case campReport(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case campReportFormat(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case camperSettings(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case updateCampers(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case setReport(error: CampsGroupingAPIError, networkCall: NetworkCall)
    case updateReportFormat(error: CampsGroupingAPIError, networkCall: NetworkCall)
}

// MARK: Leaf States

struct SignInFormState: Equatable {
    private enum Constant {
        static let minPasswordLength = 1
        static let emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
    }

    var email: String = ""
    var password: String = ""
    var scope: CampsScope = .camps

    var isValidFormData: Bool {
        isValidEmail && isValidPassword
    }

    var isValidEmail: Bool {
        (try? Constant.emailRegex.wholeMatch(in: email) != nil) ?? false
    }

    var isValidPassword: Bool {
        password.count >= Constant.minPasswordLength
    }
}

extension GrouperEventSpace.State {
    var isAuthenticated: Bool {
        accessAccount != nil
    }

    var camp: Camp? {
        camps.first { $0.info.eventNumber == selectedCamp }
    }

    mutating func beginSignIn(username: String, password: String, scope: CampsScope) -> GrouperAction {
        let networkCall: NetworkCall = .signIn()
        activeFetches.insert(networkCall)
        return .signIn(username: username, password: password, scope: scope, networkCall: networkCall)
    }
    
    mutating func beginGetCamps(account: CampAccessAccount, scope: CampsScope) -> GrouperAction {
        let networkCall: NetworkCall = .camps()
        activeFetches.insert(networkCall)
        return .getCamps(account: account, scope: scope, networkCall: networkCall)
    }
    
    mutating func beginGetReports() -> GrouperAction {
        let networkCall: NetworkCall = .campReports()
        activeFetches.insert(networkCall)
        return .getReports(networkCall: networkCall)
    }
    
    mutating func beginGetReportForCamp(campSettings: CampSettings) -> GrouperAction {
        let networkCall: NetworkCall = .campReport()
        activeFetches.insert(networkCall)
        return .getReportForCamp(campSettings: campSettings, networkCall: networkCall)
    }
    
    mutating func beginGetReportFormatForCamp(campSettings: CampSettings) -> GrouperAction {
        let networkCall: NetworkCall = .campReportFormat()
        activeFetches.insert(networkCall)
        return .getReportFormatForCamp(campSettings: campSettings, networkCall: networkCall)
    }
    
    mutating func beginGetCamperSettingsForCamp(camp: Camp) -> GrouperAction {
        let networkCall: NetworkCall = .camperSettings()
        activeFetches.insert(networkCall)
        return .getCamperSettingsForCamp(camp: camp, networkCall: networkCall)
    }
    
    mutating func beginSetReportForCamp(
        reportID: String,
        camp: Camp,
        userID: Int
    ) -> GrouperAction {
        let networkCall: NetworkCall = .setReport()
        activeFetches.insert(networkCall)
        return .setReportForCamp(
            reportID: reportID,
            camp: camp,
            userID: userID,
            networkCall: networkCall
        )
    }
    
    mutating func beginUpdateReportFormatForCamp(
        campSettings: CampSettings,
        userID: Int
    ) -> GrouperAction {
        let networkCall: NetworkCall = .updateReportFormat()
        activeFetches.insert(networkCall)
        return .updateReportFormatForCamp(
            campSettings: campSettings,
            userID: userID,
            networkCall: networkCall
        )
    }
    
    mutating func beginSetCamperAssigmentsForCamp(
        camp: Camp,
        campSettings: CampSettings,
        userID: Int
    ) -> GrouperAction {
        let networkCall: NetworkCall = .setCamperAssigments()
        activeFetches.insert(networkCall)
        return .setCamperAssigmentsForCamp(
            camp: camp,
            campSettings: campSettings,
            userID: userID,
            networkCall: networkCall
        )
    }

    var isPerformingSignInCall: Bool {
        activeFetches.contains { call in
            if case .signIn = call {
                true
            } else {
                false
            }
        }
    }
    
    var isPerformingCampsCall: Bool {
        activeFetches.contains { call in
            if case .camps = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCampReportsCall: Bool {
        activeFetches.contains { call in
            if case .campReports = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCampReportCall: Bool {
        activeFetches.contains { call in
            if case .campReport = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCampReportFormatCall: Bool {
        activeFetches.contains { call in
            if case .campReportFormat = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCamperSettingsCall: Bool {
        activeFetches.contains { call in
            if case .camperSettings = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingSetReportCall: Bool {
        activeFetches.contains { call in
            if case .setReport = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingUpdateReportFormatCall: Bool {
        activeFetches.contains { call in
            if case .updateReportFormat = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingSetCamperAssigmentsCall: Bool {
        activeFetches.contains { call in
            if case .setCamperAssigments = call {
                true
            } else {
                false
            }
        }
    }
}
