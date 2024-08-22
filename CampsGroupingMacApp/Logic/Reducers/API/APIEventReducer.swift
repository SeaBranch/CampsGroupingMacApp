enum APIEventReducer {
    static func handle(
        event: APIEvent,
        state: inout GrouperState
    ) -> [GrouperAction] {
        switch event {
        case .retryNetworkCall(let networkCall):
            RetryNetworkCallReducer.handleEvent(
                networkCall: networkCall,
                state: &state
            )
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
        case .didRespondToGetCampReports(let result, let requestData, networkCall: let networkCall):
            DidRespondToGetCampReportsReducer.handleEvent(
                result: result,
                requestData: requestData,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToGetReport(let result, let requestData, let networkCall):
            DidRespondToGetReportReducer.handleEvent(
                result: result,
                campSettings: requestData.campSettings,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToGetReportFormat(let result, let requestData, let networkCall):
            DidRespondToGetReportFormatReducer.handleEvent(
                result: result,
                requestData: requestData,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToGetCamperSettings(let result, let requestData, let networkCall):
            DidRespondToGetCamperSettingsReducer.handleEvent(
                result: result,
                requestData: requestData,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToSetReport(let result, let requestData, let networkCall):
            DidRespondToSetReportReducer.handleEvent(
                result: result,
                requestData: requestData,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToUpdateReportFormat(let result, let requestData, let networkCall):
            DidRespondToUpdateReportFormatReducer.handleEvent(
                result: result,
                requestData: requestData,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToSetCamperAssigments(let result, let requestData, let networkCall):
            DidRespondToSetCamperAssigmentsReducer.handleEvent(
                result: result,
                requestData: requestData,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToGetGroups(let result, let camp, let scope, let networkCall):
            DidRespondToGetGroupsReducer.handleEvent(
                result: result,
                camp: camp,
                scope: scope,
                networkCall: networkCall,
                state: &state
            )
        case .didRespondToUploadCamperGrouping(result: let result, requestData: let requestData, networkCall: let networkCall):
            []
        case .didRespondToMarkAssignmentAsUploaded(result: let result, requestData: let requestData, networkCall: let networkCall):
            []
        }
    }
}
