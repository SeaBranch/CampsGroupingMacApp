//
//  CampEventsResponse.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/25/24.
//

import Foundation

struct GetCampsResponse: Codable {
    let data: [CampResponse]
    let metadata: GetEventsMetaData
}
