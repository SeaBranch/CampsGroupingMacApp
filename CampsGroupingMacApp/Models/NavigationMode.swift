//
//  NavigationMode.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/16/24.
//

import Foundation

enum NavigationMode: Equatable {
    case signin // signing in
    case camps // selecting camps and adding reports to camps
    case report // edit report formats
    case grouping // grouping campers in a camp
}
