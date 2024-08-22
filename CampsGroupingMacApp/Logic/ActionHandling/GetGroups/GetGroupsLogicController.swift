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
                var groupsUsed = groups
                if groups.isEmpty {
                    groupsUsed = [
                        CampGroupDTO(
                            id: "80ff7802-9d03-45cb-aba2-3a3a325bee81",
                            groupNumber: 240198,
                            name: "Craig's Cleavers",
                            email: "aaron.peck+dribble@crossroads.net",
                            attendeeTypeId: "attendeeTypeId",
                            typeName: "Father and Son - Trip Captains (2 people)",
                            attendeeCount: 1,
                            adminPasscode: "adminPasscode",
                            joinPasscode: "joinPasscode",
                            communityId: "communityId",
                            communityPartition: "communityPartition",
                            communityName: "communityName"
                        ),
                        CampGroupDTO(
                            id: "3e3a4372-3d71-40b6-9a81-95ba7fde8255",
                            groupNumber: 240199,
                            name: "Shrinky's dinky dudes",
                            email: "aaron.peck+midrange@crossroads.net",
                            attendeeTypeId: "attendeeTypeId",
                            typeName: "Father and Son - Trip Captains (2 people)",
                            attendeeCount: 1,
                            adminPasscode: "adminPasscode",
                            joinPasscode: "joinPasscode",
                            communityId: "communityId",
                            communityPartition: "communityPartition",
                            communityName: "communityName"
                        )
                    ]
                }
                self.modelContainer.mainContext.insert(
                    CampGroupsStateMemory(
                        groups: groupsUsed,
                        scope: scope,
                        camp: camp.info.eventNumber
                    )
                )
                completion(.success(groupsUsed))
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
