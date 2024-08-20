//
//  BrushfireClient.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/14/24.
//

import Combine
import Foundation

/// common protocol to handle calls in the same array
protocol BrushfireCall {}

struct VoidCall: BrushfireCall {
    let request: URLRequest
    let domain: String
    let completion: (Result<Void, NSError>) -> Void
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
        let client = BrushfireScopeClient.client(for: scope, signInClient: call is SigninCall)
        client.brusfireTask(brushfireCall: call)
        return client.$rateLimit.eraseToAnyPublisher()
    }
}

class BrushfireScopeClient {
    private static let campsClient = BrushfireScopeClient(scope: .camps)
    private static let mancampClient = BrushfireScopeClient(scope: .manCamp)
    private static let sandboxClient = BrushfireScopeClient(scope: .sandbox)
    private static let campsSignInClient = BrushfireScopeClient(
        scope: .camps,
        signInClient: true
    )
    private static let mancampSignInClient = BrushfireScopeClient(
        scope: .manCamp,
        signInClient: true
    )
    private static let sandboxSignInClient = BrushfireScopeClient(
        scope: .sandbox,
        signInClient: true
    )

    static func client(for scope: CampsScope, signInClient: Bool) -> BrushfireScopeClient {
        switch scope {
        case .camps:    signInClient ? .campsSignInClient : .campsClient
        case .manCamp:  signInClient ? .mancampSignInClient : .mancampClient
        case .sandbox:  signInClient ? .sandboxSignInClient : .sandboxClient
        }
    }

    private let scope: CampsScope

    var name: String {
        var name =  "\(scope)"
        if isSignInClient {
            name += "_AUTH"
        }

        return name
    }

    @Published private(set) var rateLimit: RateLimit?

    private let urlSession: URLSession
    private var callQueue = [BrushfireCall]()
    private let isSignInClient: Bool

    private init(scope: CampsScope, urlSession: URLSession = .shared, signInClient: Bool = false) {
        self.scope = scope
        self.urlSession = urlSession
        self.isSignInClient = signInClient
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

            if let decodableCall = nextCall as? CampGroupsCall {
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
        let nextCallWindow = rateLimit?.nextCallWindow ?? 6
        print("waiting \(nextCallWindow) untill calling \(call.domain)")

        DispatchQueue.network.asyncAfter(deadline: .now() + nextCallWindow) {
            print("calling \(call.domain)")
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
        let nextCallWindow = rateLimit?.nextCallWindow ?? 6
        print("waiting \(nextCallWindow) untill calling \(call.domain)")
        DispatchQueue.network.asyncAfter(deadline: .now() + nextCallWindow) {
            print("calling \(call.domain)")
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
                newRateLimit.updateMessageForScopeName(self.name)
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
        let seconds = rateLimitReset.timeIntervalSince(Date())
        print("􁌴 there are \(seconds) seconds between \(Date()) and \(rateLimitReset)")
        print("     you should wait around 6 or \(seconds/Double(max(rateLimitRemaining, 1))) seconds")
        return seconds
    }

    var nextCallWindow: TimeInterval {
        if rateLimitRemaining > 0 {
            secondsTillReset / Double(max(rateLimitRemaining, 1))
        } else {
            secondsTillReset
        }
    }

    func updateMessageForScopeName(_ name: String) {
        DispatchQueue.main.async {
            GLOBAL_MESSAGES["\(name) RateLimit"] = "\(rateLimitRemaining)/600 reset: \(secondsTillReset)"
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
