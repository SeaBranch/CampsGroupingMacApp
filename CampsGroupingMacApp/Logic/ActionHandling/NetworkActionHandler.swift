import Foundation

extension DispatchQueue {
    static let processing = DispatchQueue(label: "processing", qos: .background)
}

class NetworkActionHandler: ActionHandler<GrouperEventSpace> {
    let signInLogicController: SignInLogicControllerProtocol
    let getCampsLogicController: GetCampsLogicControllerProtocol
    let groupingAPILogicController: GroupingAPILogicControllerProtocol

    init(
        signInLogicController: SignInLogicControllerProtocol
        = SignInLogicController(),
        getCampsLogicController: GetCampsLogicControllerProtocol
        = GetCampsLogicController(),
        groupingAPILogicController: GroupingAPILogicControllerProtocol
        = GroupingAPILogicController()
    ) {
        self.signInLogicController = signInLogicController
        self.getCampsLogicController = getCampsLogicController
        self.groupingAPILogicController = groupingAPILogicController
    }

    override func handle(action: GrouperEventSpace.Action, handleEvent: @escaping (GrouperEventSpace.Event) -> Void) {
        switch action {
        case .signIn(let email, let password, let scope, let networkCall):
            handleSignIn(
                username: email,
                password: password,
                scope: scope,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .getCamps(let account, let scope, let networkCall):
            handleGetCamps(
                account: account,
                scope: scope,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .getReports(let networkCall):
            handleGetReports(
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .getReportForCamp(let campSettings, let networkCall):
            handleGetReportForCamp(
                campSettings: campSettings, 
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .getReportFormatForCamp(let campSettings, let networkCall):
            handleGetReportFormatForCamp(
                campSettings: campSettings,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .getCamperSettingsForCamp(camp: let camp, let networkCall):
            handleGetCamperSettingsForCamp(
                camp: camp,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .setReportForCamp(let reportID, let camp, let userID, let networkCall):
            handleSetReportForCamp(
                reportID: reportID,
                camp: camp,
                userID: userID,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .updateReportFormatForCamp(let campSettings, let userID, let networkCall):
            handleUpdateReportFormatForCamp(
                campSettings: campSettings,
                userID: userID,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .setCamperAssigmentsForCamp(
            let camp,
            let campSettings,
            let userID,
            let networkCall
        ):
            handleSetCamperAssigmentsForCamp(
                camp: camp,
                campSettings: campSettings,
                userID: userID,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        }
    }
}
