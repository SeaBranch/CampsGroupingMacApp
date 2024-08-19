import Foundation

typealias GetCamperSettingsResult = Result<[CamperSetting], CampsGroupingAPIError>

struct GetCamperSettingsData: Equatable, CampGroupingAPIGetEndpointModel {
    typealias D = GetCamperSettingsDTO

    let endpoint: CampsGroupingEndpoint
    let camp: Camp
}

struct GetCamperSettingsDTO: Codable {
    let data: GroupingPlanDTO
    let metadata: MetaData

    struct MetaData: Codable {
        let author: String
    }
}

struct GroupingPlanDTO: Codable {
    let eventID: String
    let assignments: [GroupingPlanCamperAssignmentDTO]

    struct GroupingPlanCamperAssignmentDTO: Codable {
        let camperID: String
        let groupID: String
        let associatedCampers: String
        let status: CamperAssignmentStatus
        let notes: String
        let updatedBy: String
    }
}

enum CamperAssignmentStatus: String, Codable {
    case edited, uploaded
}

extension NetworkActionHandler {
    func handleGetCamperSettingsForCamp(
        camp: Camp,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = GetCamperSettingsData(
            endpoint: .getCamperSettings(camp: camp),
            camp: camp
        )
        groupingAPILogicController.getCamperSettings(
            requestData: data,
            networkCall: networkCall
        ) { result in
            handleEvent(
                .api(
                    event: .didRespondToGetCamperSettings(
                        result: result,
                        requestData: data,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
