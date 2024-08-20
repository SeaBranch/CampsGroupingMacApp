import Foundation

typealias SetCamperAssigmentsResult = Result<[CamperSetting], CampsGroupingAPIError>

struct UpdateCamperAssigmentsData: Equatable, CampGroupingAPIUpdateEndpointModel {
    typealias D = GetCamperSettingsDTO

    let endpoint: CampsGroupingEndpoint
    let camp: Camp
    let campSettings: CampSettings
    let camperChanges: [CamperSetting]
    let userID: Int

    var body: any RequestDTO {
        UpdateCamperAssigmentsDTO(
            changes: camperChanges.map({ setting in
                var associatedCampers = ""
                setting.associatedCampers.forEach { cid in
                    if associatedCampers.isEmpty {
                        associatedCampers += "\(cid)"
                    } else {
                        associatedCampers += ",\(cid)"
                    }
                }
                return CamperAssigmentDTO(
                    camperID: "\(setting.camperID)",
                    attendeeID: setting.attendeeID,
                    groupID: setting.groupID ?? "",
                    groupNumber: setting.groupNumber ?? 0,
                    associatedCampers: associatedCampers,
                    status: setting.status.rawValue,
                    notes: setting.notes
                )
            }),
            userID: "\(userID)"
        )
    }
}

struct UpdateCamperAssigmentsDTO: RequestDTO {
    let changes: [CamperAssigmentDTO]
    let userID: String
}

/// type given in a set grouping plan request body
struct CamperAssigmentDTO: Codable {
    let camperID: String
    let attendeeID: String
    let groupID: String
    let groupNumber: Int
    let associatedCampers: String
    let status: String
    let notes: String
};

extension NetworkActionHandler {
    func handleSetCamperAssigmentsForCamp(
        camp: Camp,
        campSettings: CampSettings,
        camperChanges: [CamperSetting],
        userID: Int,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = UpdateCamperAssigmentsData(
            endpoint: .setCamperAssigments(
                campSettings: campSettings,
                camp: camp
            ),
            camp: camp,
            campSettings: campSettings, 
            camperChanges: camperChanges,
            userID: userID
        )
        groupingAPILogicController.updateCamperAssigments(
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
