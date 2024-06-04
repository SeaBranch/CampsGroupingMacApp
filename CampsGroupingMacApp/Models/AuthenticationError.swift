//
//  AuthenticationError.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Foundation

enum AuthenticationError: Error, Equatable, Hashable, Sendable {
    case badAuthentication(NSError)
    case noAccess(NSError)
    case forbidden(NSError)
    case tooManyRequests(NSError)
    case badRequest(NSError)
    case serviceFailure(NSError)
    case unknownError

    static func fromNSError(_ nsError: NSError?) -> Self {
        guard let nsError = nsError else {
            return .unknownError
        }

        switch nsError.code {
        case 401:
            return .badAuthentication(nsError)
        case 403:
            return .forbidden(nsError)
        case 429:
            return .tooManyRequests(nsError)
        case 404:
            return .noAccess(nsError)
        default:
            return .serviceFailure(nsError)
        }
    }
}
