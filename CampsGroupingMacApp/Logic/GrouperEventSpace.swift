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
        var campsResult: Result<[CampInfo], CampsGroupingAPIError>?
        var camp: Camp?
    }

    enum Event: Equatable {
        case api(event: APIEvent)
        case signIn(event: SignInFormEvent)
        case menu(event: MenuEvent)
        case camp(event: CampSpecificEvent)
    }

    enum Action {
        case signIn(username: String, password: String, scope: CampsScope, fetchID: UUID)
        case getCamps(account: CampAccessAccount, scope: CampsScope, fetchID: UUID)
        case updateReportFormatWithField(Report, ReportFieldSetting)
        case getCampReport(CampInfo, CampsScope)
        case getReportFormatForCamp(CampInfo, Report)
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
    case signIn(UUID)
    case camps(UUID)
    case campSettings(UUID)
    case campReport(UUID)
    case updateCamp(UUID)
}

enum NetworkError: Error, Equatable, Hashable {
    case signIn(nsError: NSError, networkCall: NetworkCall)
    case camps(nsError: NSError, networkCall: NetworkCall)
    case campSettings(nsError: NSError, networkCall: NetworkCall)
    case campReport(nsError: NSError, networkCall: NetworkCall)
    case updateCamp(nsError: NSError, networkCall: NetworkCall)
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

    var camps: [CampInfo] {
        switch campsResult {
        case .success(let camps): camps
        case .failure: []
        case nil: []
        }
    }

    mutating func beginNewSignInCall(fetchID: UUID = UUID()) {
        activeFetches.insert(.signIn(fetchID))
    }

    mutating func beginNewCampsCall(fetchID: UUID = UUID()) {
        activeFetches.insert(.camps(fetchID))
    }

    mutating func beginNewCampSettingsCall(fetchID: UUID = UUID()) {
        activeFetches.insert(.campSettings(fetchID))
    }

    mutating func beginNewCampReportCall(fetchID: UUID = UUID()) {
        activeFetches.insert(.campReport(fetchID))
    }

    mutating func beginNewUpdateCampCall(fetchID: UUID = UUID()) {
        activeFetches.insert(.updateCamp(fetchID))
    }

    mutating func finishCall(_ networkCall: NetworkCall) {
        activeFetches.remove(networkCall)
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

    var isPerformingCampSettingsCall: Bool {
        activeFetches.contains { call in
            if case .campSettings = call {
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

    var isPerformingUpdateCampCall: Bool {
        activeFetches.contains { call in
            if case .updateCamp = call {
                true
            } else {
                false
            }
        }
    }
}
