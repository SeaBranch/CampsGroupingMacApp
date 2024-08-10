import Foundation

typealias GetReportFormatResult = Result<[ReportFieldSetting], CampsGroupingAPIError>

struct GetReportFormatData: Equatable, CampGroupingAPIGetEndpointModel {
    typealias D = GetReportFormatDTO
    let endpoint: CampsGroupingEndpoint
    let campSettings: CampSettings
}

struct GetReportFormatDTO: Codable {
    let data: ReportPayloadDTO
    let metadata: MetaData

    struct ReportPayloadDTO: Codable {
        let reportID: String
        let fieldSettings: [ReportFieldSettingDTO]
    }

    struct ReportFieldSettingDTO: Codable {
        let fieldName: String
        let fieldType: String
        let visable: Bool
        let primary: Bool
        let useToGroup: Bool
        let searchable: Bool
        let handleDirectly: Bool
        let updatedBy: String?
    }

    struct MetaData: Codable {
        let author: String
    }
}

extension NetworkActionHandler {
    func handleGetReportFormatForCamp(
        campSettings: CampSettings,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = GetReportFormatData(
            endpoint: .getReportFormat(
                campSettings: campSettings
            ),
            campSettings: campSettings
        )
        groupingAPILogicController.getReportFormat(
            requestData: data,
            networkCall: networkCall
        ) { result in
            handleEvent(
                .api(
                    event: .didRespondToGetReportFormat(
                        result: result,
                        requestData: data,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
