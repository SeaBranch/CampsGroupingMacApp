import Foundation

protocol GetGroupsCommunicatorProtocol {
    func getGroups(
        camp: Camp,
        scope: CampsScope,
        completion: @escaping (Result<[CampGroupDTO], NSError>) -> Void
    )
}

class GetGroupsCommunicator: GetGroupsCommunicatorProtocol {
    let client: BrushfireClientProtocol

    init(
        client: BrushfireClientProtocol = BrushfireClient()
    ) {
        self.client = client
    }

    func getGroups(
        camp: Camp,
        scope: CampsScope,
        completion: @escaping (Result<[CampGroupDTO], NSError>) -> Void
    ) {
        let endpoint = CampsGroupingEndpoint.getGroups(camp: camp)

        var request = URLRequest(
            endpoint: endpoint,
            scope: scope
        )

        _ = client.networkTask(
            scope: scope,
            call: CampGroupsCall(
                request: request,
                domain: endpoint.domain,
                completion: completion
            )
        )
    }
}

struct CampGroupsCall: BrushfireCall {
    let request: URLRequest
    let domain: String
    let completion: (Result<[CampGroupDTO], NSError>) -> Void

    var decodableCall: BrushfireDecodableCall<[CampGroupDTO]> {
        .init(request: request, domain: domain, completion: completion)
    }
}
