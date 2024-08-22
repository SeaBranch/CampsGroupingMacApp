//
//  GetGroupsAction.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/19/24.
//

import Foundation

extension NetworkActionHandler {
    func handleGetGroups(
        camp: Camp,
        scope: CampsScope,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        getGroupsLogicController.getGroups(camp: camp, scope: scope) { result in
            handleEvent(
                .api(
                    event: .didRespondToGetGroups(
                        result: result,
                        camp: camp,
                        scope: scope,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}

typealias GenerateAutoGroupingResult = [GroupingAsignment]

struct GenerateAutoGroupingData {
    let assigneeFilter: FieldFilter?
    let groupFilter: FieldFilter?
    let equivelencies: [String: Double]
}

struct GroupingAsignment: Equatable {
    let camper: Camper
    let groupID: String
}

extension NetworkActionHandler {
    func handleGenerateAutoGrouping(
        camp: Camp,
        scope: CampsScope,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        getGroupsLogicController.getGroups(camp: camp, scope: scope) { result in
            handleEvent(
                .api(
                    event: .didRespondToGetGroups(
                        result: result,
                        camp: camp,
                        scope: scope,
                        networkCall: networkCall
                    )
                )
            )
        }
    }
}
