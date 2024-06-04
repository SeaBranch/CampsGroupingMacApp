//
//  SignInPannelViewModel.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Combine
import SwiftUI

struct SignInPannelViewModelState: Equatable {
    var error: AuthenticationError?
    var isLoading: Bool
    var pannelState: SignInPannelState

    init(error: AuthenticationError? = nil, isLoading: Bool = false, pannelState: SignInPannelState = SignInPannelState()) {
        self.error = error
        self.isLoading = isLoading
        self.pannelState = pannelState
    }

    init(state: GrouperEventSpace.State) {
        self.init(
            error: state.activeSignInError,
            isLoading: state.activeSignIn != nil,
            pannelState: state.signinPannelState ?? SignInPannelState()
        )
    }
}

class SignInPannelViewModel: ObservableObject, Observable {
    @Published var vmState: SignInPannelViewModelState

    private var onEvent: (GrouperEventSpace.Event) -> Void
    private var stateSubscription: AnyCancellable?

    init(
        state: GrouperEventSpace.State,
        statePublisher: AnyPublisher<GrouperEventSpace.State, Never>,
        onEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        self.onEvent = onEvent
        vmState = .init(state: state)
        stateSubscription = statePublisher
            .map { SignInPannelViewModelState(state: $0) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.vmState, on: self)
    }

    convenience init(coordinator: EventCoordinator<GrouperEventSpace>) {
        self.init(state: coordinator.state, statePublisher: coordinator.$state.eraseToAnyPublisher()) { event in
            coordinator.send(event: event)
        }
    }

    func didSelectSignIn() {
        let pannelState = self.vmState.pannelState

        if pannelState.isValidFormData {
            onEvent(.didSelectSignIn(email: pannelState.email, password: pannelState.password))
        }
    }

    func didEditForm() {
        onEvent(.didEditSignInPannel(email: vmState.pannelState.email, password: vmState.pannelState.password))
    }
}
