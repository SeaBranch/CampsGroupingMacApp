//
//  BrushfireClient.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/14/24.
//

import Combine
import Foundation

protocol BrushfireCall {

}

struct VoidCall: BrushfireCall {
    let request: URLRequest
    let domain: String
    let completion: (Result<Void, NSError>) -> Void
}

struct SigninCall: BrushfireCall {
    let request: URLRequest
    let domain: String
    let completion: (Result<CampAccessAccount, NSError>) -> Void

    var decodableCall: BrushfireDecodableCall<CampAccessAccount> {
        .init(request: request, domain: domain, completion: completion)
    }
}

struct CampsCall: BrushfireCall {
    let request: URLRequest
    let domain: String
    let completion: (Result<[CampInfo], NSError>) -> Void

    var decodableCall: BrushfireDecodableCall<[CampInfo]> {
        .init(request: request, domain: domain, completion: completion)
    }
}

struct BrushfireDecodableCall<T> {
    let request: URLRequest
    let domain: String
    let completion: (Result<T, NSError>) -> Void
}

protocol BrushfireClientProtocol {
    /// Performs a data task with the request and sends back the success or error
    /// - Parameters:
    ///  - scope: the camps scope of the request
    ///  - call: all the information needed for the network call
    func networkTask(
        scope: CampsScope,
        call: any BrushfireCall
    ) -> AnyPublisher<RateLimit?, Never>
}

class BrushfireClient: BrushfireClientProtocol {
    /// Performs a data task with the request and sends back the success or error
    /// - Parameters:
    ///  - scope: the camps scope of the request
    ///  - call: all the information needed for the network call
    func networkTask(
        scope: CampsScope,
        call: any BrushfireCall
    ) -> AnyPublisher<RateLimit?, Never> {
        let client = BrushfireScopeClient.client(for: scope)
        client.brusfireTask(brushfireCall: call)
        return client.$rateLimit.eraseToAnyPublisher()
    }
}

class BrushfireScopeClient {
    private static let campsClient = BrushfireScopeClient(scope: .camps)
    private static let mancampClient = BrushfireScopeClient(scope: .manCamp)
    private static let sandboxClient = BrushfireScopeClient(scope: .sandbox)

    static func client(for scope: CampsScope) -> BrushfireScopeClient {
        switch scope {
        case .camps:    .campsClient
        case .manCamp:  .mancampClient
        case .sandbox:  .sandboxClient
        }
    }

    private let scope: CampsScope

    @Published private(set) var rateLimit: RateLimit?

    private let urlSession: URLSession
    private var callQueue = [BrushfireCall]()

    private init(scope: CampsScope, urlSession: URLSession = .shared) {
        self.scope = scope
        self.urlSession = urlSession
    }

    /// Performs a data task with the request and sends back the success or error
    /// - Parameters:
    ///  - request: URLRequest with all the neccessary headers and body needed for the call
    ///  - domain: url domain string used for the error if needed
    ///  - completion: escaping result closure with a void success or an NSError failure
    /// - Returns: a RateLimitStatus struct with the limit status at the time of calling.
    func brusfireTask(
        brushfireCall: any BrushfireCall
    ) {
        DispatchQueue.network.async {
            let immediate = self.callQueue.isEmpty
            self.callQueue.append(
                brushfireCall
            )

            if immediate {
                self.performNextCall()
            }
        }
    }

    private func performNextCall() {
        if let nextCall = callQueue.first {
            callQueue.removeFirst()

            if let decodableCall = nextCall as? SigninCall {
                performDecodableTask(call: decodableCall.decodableCall)
            }

            if let decodableCall = nextCall as? CampsCall {
                performDecodableTask(call: decodableCall.decodableCall)
            }

            if let passFailCall = nextCall as? VoidCall {
                performPassFailTask(call: passFailCall)
            }
        }
    }

    private func performPassFailTask(
        call: VoidCall
    ) {
        let nextCallWindow = rateLimit?.nextCallWindow ?? 0
        print("waiting \(nextCallWindow) untill calling \(call.domain)")
        DispatchQueue.network.asyncAfter(deadline: .now() + nextCallWindow) {
            self.urlSession.passFailTask(
                request: call.request,
                domain: call.domain,
                onResponse: self.handleResponse,
                completion: call.completion
            )
        }
    }

    func performDecodableTask<T: Codable>(
        call: BrushfireDecodableCall<T>
    ) {
        let nextCallWindow = rateLimit?.nextCallWindow ?? 0
        print("waiting \(nextCallWindow) untill calling \(call.domain)")
        DispatchQueue.network.asyncAfter(deadline: .now() + nextCallWindow) {
            self.urlSession.decodableTask(
                request: call.request,
                domain: call.domain,
                onResponse: self.handleResponse,
                completion: call.completion
            )
        }
    }

    private func handleResponse(_ response: URLResponse?) {
        DispatchQueue.main.async {
            guard let http = response as? HTTPURLResponse else {
                self.performNextCall()
                return
            }
            print("response headers:")

            let headers = http.allHeaderFields
            var newRateLimit: RateLimit?

            print(headers)
            
            let xrateLimitLimit = headers["x-rate-limit-limit"] as? String
            let xrateLimitRemaining = headers["x-rate-limit-remaining"] as? String
            let xrateLimitResetStr = headers["x-rate-limit-reset"] as? String

            if let rateLimitLimit = xrateLimitLimit,
               let rateLimitRemainingStr = xrateLimitRemaining,
               let rateLimitRemaining = Int(rateLimitRemainingStr),
               let rateLimitResetStr = xrateLimitResetStr,
               let rateLimitReset = Const.dateformatter.date(from: rateLimitResetStr) {

                newRateLimit = RateLimit(
                    rateLimitRemaining: rateLimitRemaining,
                    rateLimitReset: rateLimitReset,
                    rateLimitLimit: rateLimitLimit
                )
            } else if let retryAfter = headers["retry-after"] as? Int {
                newRateLimit = RateLimit(retryAfter: retryAfter)
            }

            if let newRateLimit = newRateLimit {
                self.rateLimit = newRateLimit
                print(newRateLimit)
            }

            self.performNextCall()
        }
    }
}

struct RateLimit: Equatable {
    var rateLimitRemaining: Int
    var rateLimitReset: Date
    var rateLimitLimit: String
    var retryAfter: Int?

    var referenceDate: Date

    init(
        retryAfter: Int,
        date: Date = Date()
    ) {
        self.rateLimitRemaining = 0
        self.rateLimitReset = .now.addingTimeInterval(TimeInterval(retryAfter))
        self.rateLimitLimit = "1hr"
        self.retryAfter = retryAfter
        self.referenceDate = date
    }

    init(
        rateLimitRemaining: Int,
        rateLimitReset: Date,
        rateLimitLimit: String,
        date: Date = Date()
    ) {
        self.rateLimitRemaining = rateLimitRemaining
        self.rateLimitReset = rateLimitReset
        self.rateLimitLimit = rateLimitLimit
        self.retryAfter = nil
        self.referenceDate = date
    }

    var secondsTillReset: TimeInterval {
        return rateLimitReset.timeIntervalSince(Date())
    }

    var nextCallWindow: TimeInterval {
        if rateLimitRemaining > 0 {
            secondsTillReset / Double(rateLimitRemaining)
        } else {
            secondsTillReset
        }
    }
}

enum Const {
    static let dateformatter: ISO8601DateFormatter = {
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
    }()
}
