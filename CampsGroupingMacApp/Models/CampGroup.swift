//
//  File.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/18/24.
//

import Foundation

struct CampGroup: Equatable, Hashable {
    let groupID: GroupIdentification
    let groupName: String
    let email: String
    let attendeeTypeId: String
    let type: CampGroupType
    let attendeeCount: Int
    let adminPasscode: String?
    let joinPasscode: String?
    let communityId: String?
    let communityPartition: String?
    let communityName: String?

    var groupLeader: Int?
    var campers: [Camper]

    var averageDelta: Double
    var maxAverageDelta: Double

    init(
        groupID: GroupIdentification,
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
        campers: [Camper],
        averageDelta: Double,
        maxAverageDelta: Double
    ) {
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
        self.averageDelta = averageDelta
        self.maxAverageDelta = maxAverageDelta
    }

    init(dto: CampGroupDTO, campersArray: [Camper], groupingFields: [String], equivelences: [String: Double]) {
        self.groupID = dto.groupID
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

        self.groupLeader = campersArray.first { $0.values.email == dto.email }?.id

        let campersToInsert = campersArray.filter { camperObj in
            camperObj.currentGroup?.groupNumber == dto.groupNumber
        }

        self.campers = campersToInsert

        let avgDeltas: [Double] = campersToInsert.compactMap { primaryCamper in
            campersToInsert
                .filter { $0.id != primaryCamper.id }
                .averageValuesDiff(
                    from: primaryCamper,
                    inFields: groupingFields,
                    with: equivelences
                )["AVGTOTAL"] ?? nil
        }
        
        averageDelta = avgDeltas.average ?? 0
        maxAverageDelta = avgDeltas.max() ?? 0
    }

    func averagedDifference(
        fromCamper camper: Camper,
        groupingFields: [String],
        equivelences: [String: Double]
    ) -> Double {
        (
            campers
                .filter { $0.id != camper.id }
                .averageValuesDiff(
                    from: camper,
                    inFields: groupingFields,
                    with: equivelences
                )["AVGTOTAL"] ?? nil
        ) ?? 0
    }

    func maxAveragedDifference(
        fromCamper camper: Camper,
        groupingFields: [String],
        equivelences: [String: Double]
    ) -> Double {
        campers
            .filter { $0.id != camper.id }
            .maxAverageValuesDiff(
                from: camper,
                inFields: groupingFields,
                with: equivelences
            )
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

extension Array where Element == Double {
    var average: Double? {
        guard count > 0 else { return nil }

        return self.total ?? 0 / Double(count)
    }

    var total: Double? {
        guard count > 0 else { return nil }
        
        var total: Double = 0
        for value in self {
            total += value
        }
        return total
    }
}
