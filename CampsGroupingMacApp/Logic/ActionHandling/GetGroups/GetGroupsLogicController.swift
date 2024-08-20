import Foundation
import SwiftData


protocol GetGroupsLogicControllerProtocol {
    func getGroups(
        camp: Camp,
        scope: CampsScope,
        completion: @escaping (Result<[CampGroupDTO], CampsGroupingAPIError>) -> Void
    )
}

class GetGroupsLogicController: GetGroupsLogicControllerProtocol {
    let modelContainer: ModelContainer
    let communicator: GetGroupsCommunicatorProtocol

    init(
        modelContainer: ModelContainer,
        communicator: GetGroupsCommunicatorProtocol = GetGroupsCommunicator()
    ) {
        self.modelContainer = modelContainer
        self.communicator = communicator
    }

    @MainActor
    func getGroups(
        camp: Camp,
        scope: CampsScope,
        completion: @escaping (Result<[CampGroupDTO], CampsGroupingAPIError>) -> Void
    ) {
        let groupsMemoryArray = try? modelContainer.mainContext.fetch(FetchDescriptor<CampGroupsStateMemory>())
        if let groupsMemory = groupsMemoryArray?.first(where: { groupsMem in
            groupsMem.scope == scope && groupsMem.camp == camp.info.eventNumber
        }) {
            if !groupsMemory.isStale && groupsMemory.groups.count > 0 {
                completion(.success(groupsMemory.groups))
            } else {
                modelContainer.mainContext.delete(groupsMemory)
                fetchGroups(camp: camp, scope: scope, completion: completion)
            }
        } else {
            fetchGroups(camp: camp, scope: scope, completion: completion)
        }
    }

    @MainActor
    private func fetchGroups(
        camp: Camp,
        scope: CampsScope,
        completion: @escaping (Result<[CampGroupDTO], CampsGroupingAPIError>) -> Void
    ) {
        communicator.getGroups(camp: camp, scope: scope) { result in
            let endpoint = CampsGroupingEndpoint.getGroups(camp: camp)
            switch result {
            case .success(let groups):
                self.modelContainer.mainContext.insert(
                    CampGroupsStateMemory(
                        groups: groups,
                        scope: scope,
                        camp: camp.info.eventNumber
                    )
                )
                completion(.success(groups))
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
