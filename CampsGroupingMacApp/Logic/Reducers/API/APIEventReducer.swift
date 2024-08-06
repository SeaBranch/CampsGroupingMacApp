enum APIEventReducer {
    static func handle(
        event: APIEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .didRespondToSignIn(let result, let scope, let networkCall):
            DidRespondToSignInReducer.handleEvent(
                result: result,
                scope: scope,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToGetCamps(let result, let account, let scope, let networkCall):
            DidRespondToGetCampsReducer.handleEvent(
                result: result,
                account: account,
                scope: scope,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToGetReport(let result, let camp, let scope, let networkCall):
            DidRespondToGetReportReducer.handleEvent(
                result: result,
                camp: camp,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToGetCampSettings(let result, let camp, let networkCall):
            []
        case .didRespondToUpdateCampSettings(let result, let camp, let networkCall):
            []
        }
    }
}
