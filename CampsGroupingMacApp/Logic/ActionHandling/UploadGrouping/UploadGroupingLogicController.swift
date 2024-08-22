import Foundation

protocol UploadGroupingLogicControllerProtocol {
    func uploadGrouping(
        requestData: UploadGroupAssignmentData,
        completion: @escaping (UploadGroupAssignmentResult) -> Void
    )
}

class UploadGroupingLogicController: UploadGroupingLogicControllerProtocol {

    let communicator: UploadGroupingCommunicatorProtocol

    init(
        communicator: UploadGroupingCommunicatorProtocol
        = UploadGroupingCommunicator()
    ) {
        self.communicator = communicator
    }

    func uploadGrouping(
        requestData: UploadGroupAssignmentData,
        completion: @escaping (UploadGroupAssignmentResult) -> Void
    ) {
        communicator.uploadGrouping(
            requestData: requestData
        ) { result in
            switch result {
            case .success(_):
                completion(
                    .success(
                        .init(
                            camper: requestData.camper,
                            groupID: requestData.groupID.groupId
                        )
                    )
                )
            case .failure(let nsError):
#if DEBUG
                if requestData.scope == .sandbox {
                    completion(
                        .success(
                            .init(
                                camper: requestData.camper,
                                groupID: requestData.groupID.groupId
                            )
                        )
                    )
                }
                return
#endif
                completion(.failure(
                    .fromNSError(
                        nsError,
                        endpoint: requestData.endpoint
                    )
                ))
            }
        }
    }
}

protocol UploadGroupingCommunicatorProtocol {
    func uploadGrouping(
        requestData: UploadGroupAssignmentData,
        completion: @escaping (Result<UploadGroupAssignmentResponseDTO, NSError>) -> Void
    )
}

class UploadGroupingCommunicator: UploadGroupingCommunicatorProtocol {
    let client: BrushfireClientProtocol

    init(
        client: BrushfireClientProtocol = BrushfireClient()
    ) {
        self.client = client
    }

    func uploadGrouping(requestData: UploadGroupAssignmentData, completion: @escaping (Result<UploadGroupAssignmentResponseDTO, NSError>) -> Void) {
        let request = URLRequest(
            endpoint: requestData.endpoint,
            scope: requestData.scope
        )

        _ = client.networkTask(
            scope: requestData.scope,
            call: UploadGroupingCall(
                request: request,
                domain: requestData.endpoint.domain,
                completion: completion
            )
        )
    }
}

struct UploadGroupingCall: BrushfireCall {
    let request: URLRequest
    let domain: String
    let completion: (Result<UploadGroupAssignmentResponseDTO, NSError>) -> Void

    var decodableCall: BrushfireDecodableCall<UploadGroupAssignmentResponseDTO> {
        .init(request: request, domain: domain, completion: completion)
    }
}
