import Foundation

typealias GetReportResult = Result<Report, CampsGroupingAPIError>

struct GetReportData: Equatable {
    let endpoint: CampsGroupingEndpoint
    let campSettings: CampSettings
}

extension NetworkActionHandler {
    func handleGetReportForCamp(
        campSettings: CampSettings,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = GetReportData(
            endpoint: .getReport(campSettings: campSettings),
            campSettings: campSettings
        )
        groupingAPILogicController.getReport(
            requestData: data,
            networkCall: networkCall
        ) { result in
            handleEvent(
                .api(
                    event: .didRespondToGetReport(
                        result: result,
                        requestData: data,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
