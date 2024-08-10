import Foundation

typealias UpdateReportFormatResult = Result<Bool, CampsGroupingAPIError>

struct UpdateReportFormatData: Equatable, CampGroupingAPISetEndpointModel {
    let endpoint: CampsGroupingEndpoint
    let campSettings: CampSettings
    let userID: Int

    var body: any RequestDTO {
        ReportFormatChangeDTO(
            fields: campSettings.report.reportFieldSettings.map {
                ReportFormatChangeDTO.ReportFieldSettingChangeDTO(
                    fieldName: $0.fieldName,
                    fieldType: $0.fieldType.rawValue,
                    visable: $0.visable,
                    primary: $0.isRegistrantData,
                    useToGroup: $0.includeInGrouping,
                    searchable: $0.showInTable,
                    handleDirectly: $0.handleDirectly
                )
            },
            userID: "\(userID)"
        )
    }
}

extension NetworkActionHandler {
    func handleUpdateReportFormatForCamp(
        campSettings: CampSettings,
        userID: Int,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = UpdateReportFormatData(
            endpoint: .updateReportFormat(campSettings: campSettings),
            campSettings: campSettings,
            userID: userID
        )
        groupingAPILogicController.updateReportFormat(
            requestData: data,
            networkCall: networkCall
        ) { result in
            handleEvent(
                .api(
                    event: .didRespondToUpdateReportFormat(
                        result: result,
                        requestData: data,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
