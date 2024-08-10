import Foundation

typealias GetCampReportsResult = Result<[ReportAddress], CampsGroupingAPIError>

struct GetCampReportsData: Equatable, CampGroupingAPIGetEndpointModel {
    typealias D = GetCampReportsDTO

    let endpoint: CampsGroupingEndpoint
}

struct GetCampReportsDTO: Codable {
    let data: [AddressDTO]
    let metadata: MetaData

    struct AddressDTO: Codable {
        let eventID: String //"573184",
        let reportID: String //"b2abb5b6-4e02-434e-b897-ccb18fce25aa",
        let userID: String //"2316432"
    }

    struct MetaData: Codable {
        let author: String
    }
}

extension NetworkActionHandler {
    func handleGetReports(
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = GetCampReportsData(endpoint: .getCampReports)
        groupingAPILogicController.getCampReports(requestData: data, networkCall: networkCall) { result in
            handleEvent(
                .api(
                    event: .didRespondToGetCampReports(
                        result: result,
                        requestData: data,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
