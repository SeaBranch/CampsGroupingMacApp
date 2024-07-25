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
        var accessAccount: CampAccessAccount?
        var activeSignIn: UUID?
        var activeSignInError: CampsGroupingAPIError?
        var signInFormState: SignInFormState? = SignInFormState()
        var navigationMode: NavigationMode = .signin

        var activeCampsFetch: UUID?
        var campsResult: Result<[Camp], CampsGroupingAPIError>?
        var selectedCamp: Camp?

        var report: Report?

        var scope: CampsScope? {
            switch navigationMode {
            case .signin: nil
            case .camps(let scope): scope
            case .report(_, _, let scope): scope
            }
        }

        var isAuthenticated: Bool {
            accessAccount != nil
        }

        var selectedReportID: ReportID? {
            selectedCamp?.reportID
        }

        var camps: [Camp] {
            switch campsResult {
            case .success(let camps): camps
            case .failure: []
            case nil: []
            }
        }
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

// MARK: Leaf States

struct SignInFormState: Equatable {
    private enum Constant {
        static let minPasswordLength = 8
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
