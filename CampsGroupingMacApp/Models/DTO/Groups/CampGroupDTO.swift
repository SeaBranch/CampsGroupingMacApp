//
//  CampGroupDTO.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/18/24.
//

import Foundation

struct CampGroupDTO: Codable, Equatable, Hashable {
    let id: String// "8fc23e7f-3400-4180-bd8f-18ae6ded9b2b",
    let groupNumber: Int// 224298,
    let name: String// " Attending No Longer",
    let email: String// "mancamp@crossroads.net",
    let attendeeTypeId: String// "a3a712c8-07c2-46d8-9967-396ff6c412a1",
    let typeName: String// "Camper - Joining an existing Group",
    let attendeeCount: Int// 18,
    let adminPasscode: String?// "manage",
    let joinPasscode: String?// "passcode",
    let communityId: String?// null,
    let communityPartition: String?// null,
    let communityName: String?// null

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case groupNumber = "GroupNumber"
        case name = "Name"
        case email = "Email"
        case attendeeTypeId = "AttendeeTypeId"
        case typeName = "TypeName"
        case attendeeCount = "AttendeeCount"
        case adminPasscode = "AdminPasscode"
        case joinPasscode = "JoinPasscode"
        case communityId = "CommunityId"
        case communityPartition = "CommunityPartition"
        case communityName = "CommunityName"
    }

    var groupType: CampGroupTypeDTO? {
        CampGroupTypeDTO(rawValue: typeName)
    }

    var groupID: GroupIdentification {
        GroupIdentification(groupNumber: groupNumber, groupId: id)
    }
}

enum CampGroupTypeDTO: String, Codable, Equatable, Hashable {
    case camper = "Camper - Joining an existing Group"
    case tripCaptain = "Trip Captain"
}
