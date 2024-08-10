import Foundation

extension NetworkActionHandler {
    func handleGetCamps(
        account: CampAccessAccount,
        scope: CampsScope,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        getCampsLogicController.getCamps(account: account, scope: scope) { result in
            handleEvent(
                .api(
                    event: .didRespondToGetCamps(
                        result: result,
                        account: account,
                        scope: scope,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
