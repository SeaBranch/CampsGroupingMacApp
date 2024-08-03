import Foundation

protocol GetCampsLogicControllerProtocol {
    func getCamps(
        account: CampAccessAccount,
        scope: CampsScope,
        completion: @escaping (Result<[CampInfo], CampsGroupingAPIError>) -> Void
    )
}

class GetCampsLogicController: GetCampsLogicControllerProtocol {
    let communicator: GetCampsCommunicatorProtocol

    init(communicator: GetCampsCommunicatorProtocol = GetCampsCommunicator()) {
        self.communicator = communicator
    }

    func getCamps(
        account: CampAccessAccount,
        scope: CampsScope,
        completion: @escaping (Result<[CampInfo], CampsGroupingAPIError>) -> Void
    ) {
        let accessKey = account.accessKey
        communicator.getCamps(accessKey: accessKey, scope: scope) { result in
            let endpoint = CampsGroupingEndpoint.getCamps(accessKey: accessKey)
            switch result {
            case .success(let camps):
                if camps.isEmpty {
                    completion(
                        .failure(
                            .notFound(
                                NSError(
                                    domain: endpoint.domain,
                                    code: 404
                                ),
                                endpoint
                            )
                        )
                    )
                } else {
                    completion(.success(camps))
                }
            case .failure(let error):
                if let decodingError = error as? DecodingError {
                    print("ERR:!!!!!!!!!\n\(decodingError)")
                    completion(.failure(CampsGroupingAPIError.decodingError(decodingError, endpoint)))
                } else {
                    completion(.failure(CampsGroupingAPIError.fromNSError(error as NSError, endpoint: endpoint)))
                }
            }
        }
    }
}
