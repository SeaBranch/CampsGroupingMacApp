//
//  SignInActionHandler.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Foundation

class NetworkActionHandler: ActionHandler<GrouperEventSpace> {
    let signInLogicController: SignInLogicControllerProtocol
    let getCampsLogicController: GetCampsLogicControllerProtocol

    init(
        signInLogicController: SignInLogicControllerProtocol = SignInLogicController(),
        getCampsLogicController: GetCampsLogicControllerProtocol = GetCampsLogicController()
    ) {
        self.signInLogicController = signInLogicController
        self.getCampsLogicController = getCampsLogicController
    }

    override func handle(action: GrouperEventSpace.Action, handleEvent: @escaping (GrouperEventSpace.Event) -> Void) {
        switch action {
        case .signIn(let email, let password, let scope, let fetchID):
            signInLogicController.signIn(email: email, password: password, scope: scope) { result in
                handleEvent(
                    .api(event: .didRespondToSignIn(result: result, scope: scope, fetchID: fetchID))
                )
            }
        case .getCamps(let account, let scope, let fetchID):
            getCampsLogicController.getCamps(account: account, scope: scope) { result in
                handleEvent(
                    .api(
                        event: .didRespondToGetCamps(
                            result: result,
                            account: account, 
                            scope: scope,
                            fetchID: fetchID
                        )
                    )
                )
            }
        }
    }
}
