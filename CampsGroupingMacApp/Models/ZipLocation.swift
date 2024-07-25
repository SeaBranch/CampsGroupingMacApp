//
//  ZipLocation.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/15/24.
//

import CoreLocation
import Foundation
import SwiftCSV

struct ZipLocation: Equatable {
    let zip: String
    let type: String?
    let decommissioned: String?
    let primary_city: String?
    let acceptable_cities: String?
    let unacceptable_cities: String?
    let state: String?
    let county: String?
    let timezone: String?
    let area_codes: String?
    let world_region: String?
    let country: String?
    let latitude: Double
    let longitude: Double
    let irs_estimated_population: String?

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    static let zipCodes: CSV? = {
        try? CSV<Named>(
            name: "zip_code_database",
            extension: "csv",
            bundle: .main,
            delimiter: .comma,
            encoding: .utf8
        )
    }()

    static let zipCodeDictionary = ZipLocation.fromCSV().asDictionary

    static func fromZipString(_ zipString: String) -> ZipLocation? {
        zipCodeDictionary[zipString]
    }

    func distance(from otherZip: ZipLocation) -> Double {
        location.distance(from: otherZip.location)
    }

    static func fromCSV() -> [ZipLocation] {
        guard let csv = zipCodes else { return [] }
        
        return csv.rows.compactMap { dict in
            let str_zip = dict["zip"]
            let type = dict["type"]
            let decommissioned = dict["decommissioned"]
            let primary_city = dict["primary_city"]
            let acceptable_cities = dict["acceptable_cities"]
            let unacceptable_cities = dict["unacceptable_cities"]
            let state = dict["state"]
            let county = dict["county"]
            let timezone = dict["timezone"]
            let area_codes = dict["area_codes"]
            let world_region = dict["world_region"]
            let country = dict["country"]
            let str_latitude = dict["latitude"]
            let str_longitude = dict["longitude"]
            let irs_estimated_population = dict["irs_estimated_population"]

            guard let zipCode = str_zip,
                  !zipCode.isEmpty,
                let latString = str_latitude,
                  !latString.isEmpty,
                  let latitude = Double(latString),
                  let longString = str_longitude,
                  !longString.isEmpty,
                  let longitude = Double(longString)
            else { return nil }

            return ZipLocation(
                zip: zipCode,
                type: type,
                decommissioned: decommissioned,
                primary_city: primary_city,
                acceptable_cities: acceptable_cities,
                unacceptable_cities: unacceptable_cities,
                state: state,
                county: county,
                timezone: timezone,
                area_codes: area_codes,
                world_region: world_region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                irs_estimated_population: irs_estimated_population
            )
        }
    }
}

extension Collection where Element == ZipLocation {
    var asDictionary: [String: ZipLocation] {
        var dictionary = [String: ZipLocation]()
        forEach { location in
            dictionary[location.zip] = location
        }
        return dictionary
    }
}

//00501,UNIQUE,0,Holtsville,,"Internal Revenue Service",NY,"Suffolk County",America/New_York,631,NA,US,40.81,-73.04,562
