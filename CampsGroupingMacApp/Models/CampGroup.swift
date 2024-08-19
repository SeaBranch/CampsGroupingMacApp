//
//  File.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/18/24.
//

import Foundation

struct CampGroup: Equatable, Hashable {
    let idString: String
    let groupID: Int
    let groupName: String
    let email: String
    let attendeeTypeId: String
    let type: CampGroupType
    let attendeeCount: Int
    let adminPasscode: String
    let joinPasscode: String
    let communityId: String?
    let communityPartition: String?
    let communityName: String?

    var groupLeader: Int?
    var campers: [Int]

    init(
        idString: String,
        groupID: Int,
        groupName: String,
        email: String,
        attendeeTypeId: String,
        type: CampGroupType,
        attendeeCount: Int,
        adminPasscode: String,
        joinPasscode: String,
        communityId: String?,
        communityPartition: String?,
        communityName: String?,
        groupLeader: Int,
        campers: [Int]
    ) {
        self.idString = idString
        self.groupID = groupID
        self.groupName = groupName
        self.email = email
        self.attendeeTypeId = attendeeTypeId
        self.type = type
        self.attendeeCount = attendeeCount
        self.adminPasscode = adminPasscode
        self.joinPasscode = joinPasscode
        self.communityId = communityId
        self.communityPartition = communityPartition
        self.communityName = communityName
        self.groupLeader = groupLeader
        self.campers = campers
    }

    init(dto: CampGroupDTO, campers: [Camper]) {
        self.idString = dto.id
        self.groupID = dto.groupNumber
        self.groupName = dto.name
        self.email = dto.email
        self.attendeeTypeId = dto.attendeeTypeId
        self.type = CampGroupType(dto: dto.groupType)
        self.attendeeCount = dto.attendeeCount
        self.adminPasscode = dto.adminPasscode
        self.joinPasscode = dto.joinPasscode
        self.communityId = dto.communityId
        self.communityPartition = dto.communityPartition
        self.communityName = dto.communityName

        self.groupLeader = campers.first { $0.values.email == dto.email }?.id
        self.campers = campers.filter({ $0.currentGroupID == dto.groupNumber }).map({ $0.id })
    }
}

enum CampGroupType: String, Equatable, Hashable {
    case tripCaptain, campersWithoutLeader, other

    init(dto: CampGroupTypeDTO?) {
        switch dto {
        case .camper:
            self = .campersWithoutLeader
        case .tripCaptain:
            self = .tripCaptain
        case nil:
            self = .other
        }
    }
}
