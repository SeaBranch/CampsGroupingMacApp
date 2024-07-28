//
//  NavigationMode.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/16/24.
//

import Foundation

enum NavigationMode: Equatable {
    case signin
    case camps(scope: CampsScope)
    case report(report: Report?, camp: Camp, scope: CampsScope)
    case grouping(campers: [CamperRow], camp: Camp, scope: CampsScope)
}
