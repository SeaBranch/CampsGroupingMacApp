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
