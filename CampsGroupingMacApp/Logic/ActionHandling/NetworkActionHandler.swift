import Foundation
import SwiftData

extension DispatchQueue {
    static let processing = DispatchQueue(label: "processing", qos: .background)
    static let network = DispatchQueue(label: "processing", qos: .background)
}

class NetworkActionHandler: ActionHandler<GrouperEventSpace> {
    var signInLogicController: SignInLogicControllerProtocol
    var getCampsLogicController: GetCampsLogicControllerProtocol
    var groupingAPILogicController: GroupingAPILogicControllerProtocol
    let modelContainer: ModelContainer

    init(
        modelContainer: ModelContainer
    ) {
        self.modelContainer = modelContainer
        self.signInLogicController = SignInLogicController(modelContainer: modelContainer)
        self.getCampsLogicController = GetCampsLogicController(modelContainer: modelContainer)
        self.groupingAPILogicController = GroupingAPILogicController()
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
        case .updateReportFormatForCamp(let campSettings, let fields, let userID, let networkCall):
            handleUpdateReportFormatForCamp(
                campSettings: campSettings,
                fieldsToUpdate: fields,
                userID: userID,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .setCamperAssigmentsForCamp(
            let camp,
            let campSettings,
            let camperChanges,
            let userID,
            let networkCall
        ):
            handleSetCamperAssigmentsForCamp(
                camp: camp,
                campSettings: campSettings, 
                camperChanges: camperChanges,
                userID: userID,
                networkCall: networkCall,
                handleEvent: handleEvent
            )
        case .getInitialCache:
            DispatchQueue.main.async {
                self.getCache(handleEvent: handleEvent)
            }
        }
    }

    @MainActor
    func getCache(handleEvent: @escaping (GrouperEventSpace.Event) -> Void) {
        let login = try? modelContainer.mainContext.fetch(FetchDescriptor<AppLogin>())
        handleEvent(.didGetInitialCache(login?.first))
    }
}
