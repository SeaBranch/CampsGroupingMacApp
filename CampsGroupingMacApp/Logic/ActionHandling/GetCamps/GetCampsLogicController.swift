import Foundation
import SwiftData

protocol GetCampsLogicControllerProtocol {
    func getCamps(
        account: CampAccessAccount,
        scope: CampsScope,
        completion: @escaping (Result<[CampInfo], CampsGroupingAPIError>) -> Void
    )
}

class GetCampsLogicController: GetCampsLogicControllerProtocol {
    let modelContainer: ModelContainer
    let communicator: GetCampsCommunicatorProtocol

    init(
        modelContainer: ModelContainer,
        communicator: GetCampsCommunicatorProtocol = GetCampsCommunicator()
    ) {
        self.modelContainer = modelContainer
        self.communicator = communicator
    }

    @MainActor
    func getCamps(
        account: CampAccessAccount,
        scope: CampsScope,
        completion: @escaping (Result<[CampInfo], CampsGroupingAPIError>) -> Void
    ) {
        let campsMemoryArray = try? modelContainer.mainContext.fetch(FetchDescriptor<CampsStateMemory>())
        if let campsMemory = campsMemoryArray?.first(where: { campMem in
            campMem.scope == scope
        }) {
            if Date().timeIntervalSince(campsMemory.dateCreated) <= TimeInterval(3600) {
                completion(.success(campsMemory.camps))
            } else {
                modelContainer.mainContext.delete(campsMemory)
                fetchCamps(account: account, scope: scope, completion: completion)
            }
        } else {
            fetchCamps(account: account, scope: scope, completion: completion)
        }
    }

    @MainActor
    private func fetchCamps(
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
