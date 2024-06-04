//
//  SignInActionHandler.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Foundation

class SignInActionHandler: ActionHandler<GrouperEventSpace> {
    let logicController: SignInLogicControllerProtocol

    init(logicController: SignInLogicControllerProtocol = SignInLogicController()) {
        self.logicController = logicController
    }

    override func handle(action: GrouperEventSpace.Action, handleEvent: @escaping (GrouperEventSpace.Event) -> Void) {
        switch action {
        case .signIn(let email, let password, let fetchID):
            logicController.signIn(email: email, password: password) { result in
                switch result {
                case .success(let success):
                    handleEvent(.didSignIn(accounts: success, fetchID: fetchID))
                case .failure(let failure):
                    handleEvent(.didFailSignIn(fetchID: fetchID, error: failure))
                }
            }
        }
    }
}
