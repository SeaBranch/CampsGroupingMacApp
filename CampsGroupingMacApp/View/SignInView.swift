//
//  SignInPannelView.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Combine
import SwiftUI

private enum Constant {
    static let formMaxWidth: CGFloat = 320
    static let majorSpacing: CGFloat = 20
    static let minorSpacing: CGFloat = 4
}

struct SignInView: View {
    @EnvironmentObject var signInViewModel: SignInViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                signInForm()
                    .frame(maxWidth: Constant.formMaxWidth)
                Spacer()
            }
            Spacer()
        }.overlay {
            if let error = signInViewModel.vmState.error {
                errorOverlay(error: error)
            }
        }
    }

    // MARK: - Subviews
    @ViewBuilder
    fileprivate func signInForm() -> some View {
        VStack(spacing: Constant.majorSpacing) {
            VStack(spacing: Constant.minorSpacing) {
                emailField()
                passwordField()
            }

            signInButton()
        }
    }

    @ViewBuilder
    fileprivate func errorOverlay(error: AuthenticationError) -> some View {
        VStack {
            switch error {
            case .badAuthentication(let nSError):
                Text("Bad Authentication: \(nSError.code)")
                    .foregroundStyle(.red)
            case .noAccess(let nSError):
                Text("No Access Found: \(nSError.code)")
                    .foregroundStyle(.red)
            case .forbidden(let nSError):
                Text("Forbidden: \(nSError.code)")
                    .foregroundStyle(.red)
            case .tooManyRequests(let nSError):
                Text("Too Many Requests have been made: \(nSError.code)")
                    .foregroundStyle(.red)
            case .badRequest(let nSError):
                Text("Bad Request: \(nSError.code)")
                    .foregroundStyle(.red)
            case .serviceFailure(let nSError):
                Text("Service Error: \(nSError.code)")
                    .foregroundStyle(.red)
            case .unknownError:
                Text("Unknown Error :(")
                    .foregroundStyle(.red)
            case .decodingError(let decodingError):
                Text("Could Not Decode Data")
                Text("\(decodingError)")
            }
            Spacer()
        }
    }

    @ViewBuilder
    fileprivate func emailField() -> some View {
        TextField(text: $signInViewModel.vmState.formState.email) {
            Text(Strings.email)
        }
        .textFieldStyle(.roundedBorder)
        .onChange(of: signInViewModel.vmState.formState.email) { old, new in
            if old != new {
                signInViewModel.didEditForm()
            }
        }
    }
    
    @ViewBuilder
    fileprivate func passwordField() -> some View {
        SecureField(text: $signInViewModel.vmState.formState.password) {
            Text(Strings.password)
        }
        .textFieldStyle(.roundedBorder)
        .onChange(of: signInViewModel.vmState.formState.password) { old, new in
            if old != new {
                signInViewModel.didEditForm()
            }
        }
    }
    
    @ViewBuilder
    fileprivate func signInButton() -> some View {
        Button {
            signInViewModel.didSelectSignIn()
        } label: {
            HStack {
                Spacer()
                if signInViewModel.vmState.isLoading {
                    HStack {
                        ProgressView()
                        Text(Strings.signingIn)
                    }
                } else {
                    Text(Strings.signIn)
                }
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
        .disabled(
            signInViewModel.vmState.isLoading
            ||
            !signInViewModel.vmState.formState.isValidFormData
        )
    }
}

#Preview {
    SignInView()
        .environmentObject(
            SignInViewModel(
                state: GrouperEventSpace.State(),
                statePublisher: Just(GrouperEventSpace.State()).eraseToAnyPublisher(),
                onEvent: { _ in }
            )
        )
}
