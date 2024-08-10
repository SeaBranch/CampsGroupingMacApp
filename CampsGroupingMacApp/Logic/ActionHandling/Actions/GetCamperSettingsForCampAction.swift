import Foundation

typealias GetCamperSettingsResult = Result<[CamperSetting], CampsGroupingAPIError>

struct GetCamperSettingsData: Equatable, CampGroupingAPIGetEndpointModel {
    typealias D = GetCamperSettingsDTO

    let endpoint: CampsGroupingEndpoint
    let camp: Camp
}

struct GetCamperSettingsDTO: Codable {
    let data: [CamperSettingDTO]
    let metadata: MetaData

    struct CamperSettingDTO: Codable {
        let camperID: String
        let groupID: String?
        let associations: String?
        let handled: Bool?
        let autoGrouped: Bool?
        let updatedBy: String?
    }

    struct MetaData: Codable {
        let author: String
    }
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
