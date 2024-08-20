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

typealias UploadGroupAssignmentResult = Result<GroupingAsignment, CampsGroupingAPIError>

struct UploadGroupAssignmentData: 
    Equatable,
    CampGroupingAPIUpdateEndpointModel {

    typealias D = UploadGroupAssignmentResponseDTO

    let camper: Camper
    let groupID: String
    let account: CampAccessAccount
    var endpoint: CampsGroupingEndpoint

    var body: any RequestDTO {
        UploadGroupAssignmentRequestDTO(
            groupId: groupID,
            overrideCommunityCapacity: false,
            accessKey: account.accessKey
        )
    }
}

struct UploadGroupAssignmentRequestDTO: RequestDTO {
    let groupId: String
    let overrideCommunityCapacity: Bool
    let accessKey: String

    enum CodingKeys: String, CodingKey {
        case groupId = "GroupId"
        case overrideCommunityCapacity = "OverrideCommunityCapacity"
        case accessKey = "AccessKey"
    }
}

struct UploadGroupAssignmentResponseDTO: Codable {
    let Id: String?
    let AttendeeNumber: Int?
    let AttendeeCode: String?
    let EventId: String?
    let EventNumber: Int?
    let Status: String?
    let IsCompleted: Bool?
    let IsGift: Bool?
    let IsPreRegistered: Bool?
    let IsPrinted: Bool?
    let ShareEmail: String?
    let GiftLastSentAt: String?
    let FirstName: String?
    let LastName: String?
    let Phone: String?
    let Email: String?
    let Street1: String?
    let Street2: String?
    let City: String?
    let Region: String?
    let Country: String?
    let PostalCode: String?
    let TypeId: String?
    let TypeName: String?
    let SectionName: String?
    let RowName: String?
    let SeatLabel: String?
    let Wheelchair: String?
    let LimitedView: String?
    let Amount: Double?
    let SeatInfo: String?
    let CommunityId: String?
    let CommunityName: String?
    let CommunityPartition: String?
    let GroupId: String?
    let GroupName: String?
    let GroupEmail: String?
    let Fields: [GroupField]?
    let OrderFields: [GroupField]?
    let GroupFields: [GroupField]?
    let Checkins: [Checkin]?
    let IsAnonymized: Bool?
    let AttendeeDisplay: [String: String]?
    let OrderedAt: String?
    let ShareEnabled: Bool?

    struct Checkin: Codable {
        let Name: String?
        let SessionNumber: Int?
        let CheckedInAt: String?
        let CheckedIn: Bool?
        let IsHidden: Bool?
    }

    struct GroupField: Codable {
        let Id: String?
        let Label: String?
        let Value: String?
        let groupFieldType: String?
        let IsSensitive: Bool?
        let OptionIds: [String]?

        enum CodingKeys: String, CodingKey {
            case Id
            case Label
            case Value
            case groupFieldType = "Type"
            case IsSensitive
            case OptionIds
        }
    }
}

extension NetworkActionHandler {
    func handleUploadGroupAssignment(
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


typealias MarkUploadedResult = Result<[CamperSetting], CampsGroupingAPIError>
struct MarkUploadedData: Equatable, CampGroupingAPIUpdateEndpointModel {

    typealias D = GetCamperSettingsDTO

    let camper: Camper
    let groupNumber: Int
    let account: CampAccessAccount
    let camp: Camp
    let campSettings: CampSettings
    var endpoint: CampsGroupingEndpoint
    let notes: String

    var body: any RequestDTO {
        var associatedCampers = ""
        camper.associatedCamperIDs.forEach { cid in
            if associatedCampers.isEmpty {
                associatedCampers += "\(cid)"
            } else {
                associatedCampers += ",\(cid)"
            }
        }

        return UpdateCamperAssigmentsDTO(
            changes: [
                CamperAssigmentDTO(
                    camperID: "\(camper.id)",
                    groupID: "\(groupNumber)",
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
