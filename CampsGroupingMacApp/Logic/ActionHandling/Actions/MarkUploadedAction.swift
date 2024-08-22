//
//  MarkUploadedAction.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/22/24.
//

import Foundation

typealias MarkUploadedResult = Result<[CamperSetting], CampsGroupingAPIError>
struct MarkUploadedData: Equatable, CampGroupingAPIUpdateEndpointModel {

    typealias D = GetCamperSettingsDTO

    let assignment: CamperAssignment
    let account: CampAccessAccount
    let camp: Camp
    var endpoint: CampsGroupingEndpoint
    let notes: String

    var body: any RequestDTO {
        var associatedCampers = ""
        assignment.camper.associatedCamperIDs.forEach { cid in
            if associatedCampers.isEmpty {
                associatedCampers += "\(cid)"
            } else {
                associatedCampers += ",\(cid)"
            }
        }

        return UpdateCamperAssigmentsDTO(
            changes: [
                CamperAssigmentDTO(
                    camperID: "\(assignment.camper.id)",
                    attendeeID: assignment.camper.attendeeID,
                    groupID: assignment.group.groupId,
                    groupNumber: assignment.group.groupNumber,
                    associatedCampers: associatedCampers,
                    status: CamperAssignmentStatus.uploaded.rawValue,
                    notes: notes
                )
            ],
            userID: "\(account.accountNumber)"
        )
    }
}

extension NetworkActionHandler {
    func handleMarkAssignmentAsUploaded(
        assignment: CamperAssignment,
        account: CampAccessAccount,
        camp: Camp,
        notes: String,
        networkCall: NetworkCall,
        handleEvent: @escaping (GrouperEventSpace.Event) -> Void
    ) {
        let data = MarkUploadedData(
            assignment: assignment,
            account: account,
            camp: camp,
            endpoint: .markCamperAssigmentUpload(camp: camp),
            notes: notes
        )

        groupingAPILogicController.markUploaded(
            requestData: data,
            networkCall: networkCall
        ) { result in
            handleEvent(.api(
                event: .didRespondToMarkAssignmentAsUploaded(
                    result: result,
                    requestData: data,
                    networkCall: networkCall
                )
            ))
        }
    }
}
