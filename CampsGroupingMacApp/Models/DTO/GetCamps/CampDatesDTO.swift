//
//  CampDatesDTO.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/25/24.
//

import Foundation

struct CampDatesDTO: Codable, Equatable, Hashable {
    let doorsAt: Date?
    let startsAt: Date?
    let endsAt: Date?

    enum CodingKeys: String, CodingKey {
        case doorsAt = "DoorsAt"
        case startsAt = "StartsAt"
        case endsAt = "EndsAt"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.doorsAt = try container.decodeIfPresent(String.self, forKey: .doorsAt)?.asDate
        self.startsAt = try container.decodeIfPresent(String.self, forKey: .startsAt)?.asDate
        self.endsAt = try container.decodeIfPresent(String.self, forKey: .endsAt)?.asDate
    }

    func translateToModel() -> CampDatesSet? {
        guard let doorsAt = doorsAt,
              let startsAt = startsAt,
              let endsAt = endsAt
        else {
            return nil
        }

        return CampDatesSet(
            doorsAt: doorsAt,
            startsAt: startsAt,
            endsAt: endsAt
        )
    }
}

private extension String {
    // 2024-06-25T15:02:02.550Z
    static var dateformatter: ISO8601DateFormatter {
        var formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withTimeZone,
            .withTime,
            .withDashSeparatorInDate,
            .withFractionalSeconds,
            .withColonSeparatorInTime
        ]
        return formatter
    }

    var asDate: Date? {
        Self.dateformatter.date(from: self)
    }
}

extension Collection where Element == CampDatesDTO {
    func translatedToModels() -> [CampDatesSet] {
        compactMap { dto in
            dto.translateToModel()
        }
    }
}
