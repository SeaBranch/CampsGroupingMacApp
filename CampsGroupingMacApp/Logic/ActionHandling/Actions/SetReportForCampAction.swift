import Foundation

typealias SetReportResult = Result<Bool, CampsGroupingAPIError>

struct SetReportData: Equatable, CampGroupingAPISetEndpointModel {
    let endpoint: CampsGroupingEndpoint
    let camp: Camp
    let reportID: String
    let userID: Int

    var body: any RequestDTO {
        ReportAddressDTO(
            campID: "\(camp.info.eventNumber)",
            reportID: reportID,
            userID: "\(userID)"
        )
    }
}

struct ReportAddressDTO: RequestDTO, Equatable {
    let campID: String
    let reportID: String
    let userID: String
}

extension NetworkActionHandler {
    func handleSetReportForCamp(
        reportID: String,
        camp: Camp,
        userID: Int,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = SetReportData(
            endpoint: .setReport(reportID: reportID, camp: camp),
            camp: camp,
            reportID: reportID,
            userID: userID
        )
        groupingAPILogicController.setReport(
            requestData: data,
            networkCall: networkCall
        ) { result in
            handleEvent(
                .api(
                    event: .didRespondToSetReport(
                        result: result,
                        requestData: data,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
