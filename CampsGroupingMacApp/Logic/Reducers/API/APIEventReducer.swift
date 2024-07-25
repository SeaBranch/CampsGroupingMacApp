enum APIEventReducer {
    static func handle(
        event: APIEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .didRespondToSignIn(let result, let scope, let fetchID):
            DidRespondToSignInReducer.handleEvent(
                result: result, 
                scope: scope,
                fetchID: fetchID,
                state: &state
            )
        case .didRespondToGetCamps(let result, let account, let scope, let fetchID):
            DidRespondToGetCampsReducer.handleEvent(
                result: result,
                account: account,
                scope: scope,
                fetchID: fetchID,
                state: &state
            )
        case .didRespondToGetReport(let result, let camp, let scope, let fetchID):
            DidRespondToGetReportReducer.handleEvent(
                result: result,
                camp: camp,
                fetchID: fetchID,
                state: &state
            )
        }
    }
}
