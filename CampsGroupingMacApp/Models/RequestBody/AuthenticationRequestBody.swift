//
//  AuthenticationRequestBody.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/25/24.
//

import Foundation

struct AuthenticationRequestBody: Codable {
    let username: String
    let password: String

    var data: Data {
        (try? JSONEncoder.shared.encode(self)) ?? Data()
    }

    enum CodingKeys: String, CodingKey {
        case username = "Email"
        case password = "Password"
    }
}

extension JSONEncoder {
    static let shared: JSONEncoder = JSONEncoder()
}
