//
//  SignInPannelViewModel.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Combine
import SwiftUI

struct SignInViewModelState: Equatable {
    var error: NetworkError?
    var isLoading: Bool
    var formState: SignInFormState

    init(error: NetworkError? = nil, isLoading: Bool = false, formState: SignInFormState = SignInFormState()) {
        self.error = error
        self.isLoading = isLoading
        self.formState = formState
    }

    init(state: GrouperEventSpace.State) {
        self.init(
            error: state.errors.first(where: { error in
                if case .signIn(let error, let networkCall) = error {
                    true
                } else {
                    false
                }
            }),
            isLoading: state.isPerformingSignInCall,
            formState: state.signInFormState ?? SignInFormState()
        )
    }
}

class SignInViewModel: ObservableObject, Observable {
    @Published var vmState: SignInViewModelState

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
            .map { SignInViewModelState(state: $0) }
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
        let pannelState = self.vmState.formState

        if pannelState.isValidFormData {
            onEvent(.signIn(event: .didSelectSignIn(email: pannelState.email, password: pannelState.password, scope: pannelState.scope)))
        }
    }

    func didEditForm() {
        onEvent(.signIn(event: .didEditSignInForm(email: vmState.formState.email, password: vmState.formState.password, scope: vmState.formState.scope)))
    }
}
