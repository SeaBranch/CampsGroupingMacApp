//
//  SignInPannelView.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Combine
import SwiftUI

struct SignInPannelView: View {
    @EnvironmentObject var signInViewModel: SignInPannelViewModel

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        TextField(text: $signInViewModel.vmState.pannelState.email) {
                            Text("Email")
                        }
                        .onChange(of: signInViewModel.vmState.pannelState.email) { _, _ in
                            signInViewModel.didEditForm()
                        }

                        SecureField(text: $signInViewModel.vmState.pannelState.password) {
                            Text("Password")
                        }
                        .onChange(of: signInViewModel.vmState.pannelState.password) { _, _ in
                            signInViewModel.didEditForm()
                        }
                    }

                    Button {
                        signInViewModel.didSelectSignIn()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign In")
                            Spacer()
                        }
                    }
                    .disabled(signInViewModel.vmState.isLoading || !signInViewModel.vmState.pannelState.isValidFormData)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    SignInPannelView()
        .environmentObject(
            SignInPannelViewModel(
                state: GrouperEventSpace.State(),
                statePublisher: Just(GrouperEventSpace.State()).eraseToAnyPublisher(),
                onEvent: { _ in }
            )
        )
}
