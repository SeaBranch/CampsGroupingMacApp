import Foundation

typealias SetCamperAssigmentsResult = Result<Bool, CampsGroupingAPIError>

struct SetCamperAssigmentsData: Equatable, CampGroupingAPISetEndpointModel {
    let endpoint: CampsGroupingEndpoint
    let camp: Camp
    let campSettings: CampSettings
    let userID: Int

    var body: any RequestDTO {
        SetCamperAssigmentsDTO(
            camperSettings: campSettings.campers,
            eventID: "\(campSettings.report.campEventNumber)",
            userID: "\(userID)"
        )
    }
}

struct SetCamperAssigmentsDTO: RequestDTO {
    let camperSettings: [CamperSetting]
    let eventID: String
    let userID: String
}

extension NetworkActionHandler {
    func handleSetCamperAssigmentsForCamp(
        camp: Camp,
        campSettings: CampSettings,
        userID: Int,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = SetCamperAssigmentsData(
            endpoint: .setCamperAssigments(
                campSettings: campSettings,
                camp: camp
            ),
            camp: camp,
            campSettings: campSettings,
            userID: userID
        )
        groupingAPILogicController.setCamperAssigments(
            requestData: data,
            networkCall: networkCall
        ) { result in
            handleEvent(
                .api(
                    event: .didRespondToSetCamperAssigments(
                        result: result,
                        requestData: data,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
