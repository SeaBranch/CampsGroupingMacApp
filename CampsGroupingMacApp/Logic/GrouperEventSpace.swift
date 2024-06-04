//
//  GrouperEventSpace.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 5/30/24.
//

import Foundation

enum GrouperEventSpace: EventSpace {
    struct State: Equatable {
        var accounts: [CampAccessAccount] = []
        var activeSignIn: UUID?
        var activeSignInError: AuthenticationError?
        var signinPannelState: SignInPannelState? = SignInPannelState()

        var isAuthenticated: Bool {
            !accounts.isEmpty
        }
    }

    enum Event {
        case didSignOut
        case didEditSignInPannel(email: String, password: String)
        case didSelectSignIn(email: String, password: String, fetchID: UUID = UUID())
        case didSignIn(accounts: [CampAccessAccount], fetchID: UUID)
        case didFailSignIn(fetchID: UUID, error: AuthenticationError)
    }

    enum Action {
        case signIn(username: String, password: String, fetchID: UUID)
    }

    static func handle(event: Event, state: inout State) -> [Action] {
        switch event {
        case .didSignOut:
            state.signinPannelState = SignInPannelState()
            state.accounts = []
            state.activeSignIn = nil
            state.activeSignInError = nil
        case .didEditSignInPannel(let email, let password):
            state.signinPannelState = SignInPannelState(email: email, password: password)
        case .didSelectSignIn(let username, let password, let fetchID):
            state.activeSignIn = fetchID
            return [.signIn(username: username, password: password, fetchID: fetchID)]
        case .didSignIn(let accounts, let fetchID):
            if state.activeSignIn == fetchID {
                state.activeSignIn = nil
                state.accounts = accounts
                state.signinPannelState = nil
            }
        case .didFailSignIn(let fetchID, let error):
            if state.activeSignIn == fetchID {
                state.activeSignIn = nil
                state.accounts = []
                state.activeSignInError = error
            }
        }

        return []
    }
}

// MARK: Leaf States

struct SignInPannelState: Equatable {
    private enum Constant {
        static let minPasswordLength = 8
        static let emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
    }

    var email: String = ""
    var password: String = ""

    var isValidFormData: Bool {
        false
    }

    var isValidEmail: Bool {
        (try? Constant.emailRegex.wholeMatch(in: email) != nil) ?? false
    }

    var isValidPassword: Bool {
        password.count >= Constant.minPasswordLength
    }
}
