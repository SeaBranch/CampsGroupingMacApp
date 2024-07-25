//
//  HashID.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/25/24.
//

import Foundation

protocol HashID: Hashable, Identifiable {}

extension HashID {
    var id: Int { hashValue }
}
