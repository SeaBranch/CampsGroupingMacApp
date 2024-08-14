//
//  Search.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/25/24.
//

import Foundation

enum Search {
    struct CamperResult {
        let resultingCampers: [CamperRowResult]

        init(query: String, camperRows: [Camper], fullNamesOnly: Bool = false) {
            if query.isEmpty {
                resultingCampers = camperRows.map { CamperRowResult(camper: $0) }
            } else {
                let results = camperRows.compactMap {
                    CamperRowResult(
                        query: query,
                        camper: $0,
                        fullNamesOnly: fullNamesOnly
                    )
                }
                var rows = [CamperRowResult]()
                for rank in 0...4 {
                    let rankedRows = rows.filter { result in
                        result.rank == rank
                    }

                    rows.append(contentsOf: rankedRows)
                }

                resultingCampers = rows
            }
        }
    }

    struct CamperRowResult {
        let camper: Camper
        let rank: Int
        let matchingFields: [ReportFieldValue: [Range<String.Index>]]

        init(camper: Camper) {
            self.camper = camper
            self.rank = 0
            self.matchingFields = [:]
        }

        init?(query: String, camper: Camper, fullNamesOnly: Bool = false) {
            self.camper = camper
            let values = if fullNamesOnly {
                camper.values.filter({ field in
                    if case .fullName = field.value {
                        return true
                    } else {
                        return false
                    }
                })
            } else {
                camper.values
            }

            var matches = [ReportFieldValue: [Range<String.Index>]]()
            var bestMatch = Int.max

            for value in values {
                let firstMatch = Search.firstMatchIn(value: value.value, forQuery: query)
                if !firstMatch.0.isEmpty {
                    matches[value.value] = firstMatch.0
                    if bestMatch > firstMatch.1 {
                        bestMatch = firstMatch.1
                    }
                }
            }

            if matches.isEmpty { return nil }
            
            self.rank = bestMatch
            self.matchingFields = matches
        }
    }

    static func firstMatchIn(value: ReportFieldValue, forQuery query: String) -> ([Range<String.Index>], Int) {
        guard !query.isEmpty, !value.rawValue.isEmpty else { return ([], 0) }
        let target = value.rawValue

        if let range = searchExaclyMatchesString(query: query, target: target) {
            return ([range], 0)
        }

        if let range = searchPrefixesString(query: query, target: target) {
            return ([range], 1)
        }

        if let range = searchContainedInString(query: query, target: target) {
            return ([range], 2)
        }

        let rangesPartiallyPrefixing = searchPartiallyPrefixesString(
            query: query,
            target: target
        )
        if !rangesPartiallyPrefixing.isEmpty {
            return (rangesPartiallyPrefixing, 3)
        }

        let rangesMatching = searchMatchesString(query: query, target: target)
        if rangesMatching.0 {
            return (rangesMatching.1, 4)
        }

        return ([], 0)
    }

    /// rank 0
    static func searchExaclyMatchesString(query: String, target: String) -> Range<String.Index>? {
        guard !query.isEmpty, !target.isEmpty else { return nil }

        if query == target {
            return target.range(of: query, options: .literal)
        } else {
            return nil
        }
    }

    /// rank 1
    static func searchPrefixesString(query: String, target: String) -> Range<String.Index>? {
        guard !query.isEmpty, !target.isEmpty else { return nil }

        if target.prefix(query.count) == query {
            return target.range(of: query, options: .literal)
        } else {
            return nil
        }
    }

    /// rank 2
    static func searchContainedInString(query: String, target: String) -> Range<String.Index>? {
        guard !query.isEmpty, !target.isEmpty else { return nil }

        if target.contains(query) {
            return target.range(of: query, options: .literal)
        }

        return nil
    }

    /// rank 3
    static func searchPartiallyPrefixesString(query: String, target: String) -> [Range<String.Index>] {
        guard !query.isEmpty, !target.isEmpty else { return [] }

        var prefixSize = 1

        while query.contains(target.prefix(prefixSize)) {
            prefixSize += 1
        }
        prefixSize -= 1

        if prefixSize > 0 {
            let match = searchMatchesString(query: query, target: target)
            return if match.0 {
                match.1
            } else {
                []
            }
        } else {
            return []
        }

    }

    /// rank 4
    static func searchMatchesString(query: String, target: String) -> (Bool, [Range<String.Index>]) {
        guard !query.isEmpty, !target.isEmpty else { return (false, []) }

        var subString = target
        var ranges: [Range<String.Index>] = []
        for char in query {
            if let range = subString.range(of: "\(char)", options: .literal) {
                ranges.append(range)
                subString = "\(subString[range.upperBound...])"
            } else {
                return (false, [])
            }
        }

        return (true, ranges)
    }
}
