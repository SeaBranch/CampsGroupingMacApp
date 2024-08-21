//
//  GrouperState.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 8/16/24.
//

import Foundation

extension GrouperEventSpace.State {
    var isAuthenticated: Bool {
        accessAccount != nil
    }

    var camp: Camp? {
        guard let selection = selectedCamp else {
            return nil
        }

        return camps.first { camp in
            camp.info.eventNumber == selection
        }
    }

    mutating func beginSignIn(username: String, password: String, scope: CampsScope) -> GrouperAction {
        let networkCall: NetworkCall = .signIn()
        activeFetches.insert(networkCall)
        return .signIn(username: username, password: password, scope: scope, networkCall: networkCall)
    }

    mutating func beginGetCamps(account: CampAccessAccount, scope: CampsScope) -> GrouperAction {
        let networkCall: NetworkCall = .camps()
        activeFetches.insert(networkCall)
        return .getCamps(account: account, scope: scope, networkCall: networkCall)
    }

    mutating func beginGetGroupsForCamp(camp: Camp, scope: CampsScope) -> GrouperAction {
        let networkCall: NetworkCall = .groups()
        activeFetches.insert(networkCall)
        return .getGroupsForCamp(camp: camp, scope: scope, networkCall: networkCall)
    }

    mutating func beginGetReports() -> GrouperAction {
        let networkCall: NetworkCall = .campReports()
        activeFetches.insert(networkCall)
        return .getReports(networkCall: networkCall)
    }

    mutating func beginGetReportForCamp(campSettings: CampSettings) -> GrouperAction {
        let networkCall: NetworkCall = .campReport()
        activeFetches.insert(networkCall)
        return .getReportForCamp(campSettings: campSettings, networkCall: networkCall)
    }

    mutating func beginGetReportFormatForCamp(campSettings: CampSettings) -> GrouperAction {
        let networkCall: NetworkCall = .campReportFormat()
        activeFetches.insert(networkCall)
        return .getReportFormatForCamp(campSettings: campSettings, networkCall: networkCall)
    }

    mutating func beginGetCamperSettingsForCamp(camp: Camp) -> GrouperAction {
        let networkCall: NetworkCall = .camperSettings()
        activeFetches.insert(networkCall)
        return .getCamperSettingsForCamp(camp: camp, networkCall: networkCall)
    }

    mutating func beginSetReportForCamp(
        reportID: String,
        camp: Camp,
        userID: Int
    ) -> GrouperAction {
        let networkCall: NetworkCall = .setReport()
        activeFetches.insert(networkCall)
        return .setReportForCamp(
            reportID: reportID,
            camp: camp,
            userID: userID,
            networkCall: networkCall
        )
    }

    mutating func beginUpdateReportFormatForCamp(
        campSettings: CampSettings,
        settingsToUpdate: [ReportFieldSetting],
        userID: Int
    ) -> GrouperAction {
        let networkCall: NetworkCall = .updateReportFormat()
        activeFetches.insert(networkCall)
        return .updateReportFormatForCamp(
            campSettings: campSettings,
            fieldsToUpdate: settingsToUpdate,
            userID: userID,
            networkCall: networkCall
        )
    }

    mutating func beginSetCamperAssigmentsForCamp(
        camp: Camp,
        campSettings: CampSettings,
        camperChanges: [CamperSetting],
        userID: Int
    ) -> GrouperAction {
        let networkCall: NetworkCall = .setCamperAssigments()
        activeFetches.insert(networkCall)
        return .setCamperAssigmentsForCamp(
            camp: camp, 
            campSettings: campSettings,
            camperChanges: camperChanges,
            userID: userID,
            networkCall: networkCall
        )
    }

    mutating func beginUploadGroupAssignment(
        camper: Camper,
        groupID: GroupIdentification,
        account: CampAccessAccount
    ) -> GrouperAction {
        let networkCall: NetworkCall = .uploadGroupAssignment()
        activeFetches.insert(networkCall)
        return .uploadGroupAssignment(
            camper: camper,
            groupID: groupID,
            account: account,
            networkCall: networkCall
        )
    }

    mutating func beginMarkAssignmentAsUploaded(
        camper: Camper,
        groupID: GroupIdentification,
        camp: Camp,
        networkCall: NetworkCall
    ) -> GrouperAction {
        let networkCall: NetworkCall = .markAssignmentAsUploaded()
        activeFetches.insert(networkCall)
        return .markAssignmentAsUploaded(
            camper: camper,
            groupID: groupID,
            camp: camp,
            networkCall: networkCall
        )
    }

    var currentFields: [ReportFieldSetting] {
        camp?.currentFields ?? []
    }

    var isPerformingSignInCall: Bool {
        activeFetches.contains { call in
            if case .signIn = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCampsCall: Bool {
        activeFetches.contains { call in
            if case .camps = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCampReportsCall: Bool {
        activeFetches.contains { call in
            if case .campReports = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCampReportCall: Bool {
        activeFetches.contains { call in
            if case .campReport = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCampReportFormatCall: Bool {
        activeFetches.contains { call in
            if case .campReportFormat = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingCamperSettingsCall: Bool {
        activeFetches.contains { call in
            if case .camperSettings = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingSetReportCall: Bool {
        activeFetches.contains { call in
            if case .setReport = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingUpdateReportFormatCall: Bool {
        activeFetches.contains { call in
            if case .updateReportFormat = call {
                true
            } else {
                false
            }
        }
    }

    var isPerformingSetCamperAssigmentsCall: Bool {
        activeFetches.contains { call in
            if case .setCamperAssigments = call {
                true
            } else {
                false
            }
        }
    }

    struct ErrorInfo {
        let error: CampsGroupingAPIError
        let networkCall: NetworkCall

        init(_ error: CampsGroupingAPIError, _ networkCall: NetworkCall) {
            self.error = error
            self.networkCall = networkCall
        }
    }

    var campsErrorInfo: ErrorInfo? {
        let error = errors.first { error in
            if case .camps = error {
                true
            } else {
                false
            }
        }

        switch error {
        case .camps(let grouperError, let networkCall):
            return ErrorInfo(grouperError, networkCall)
        default:
            return nil
        }
    }

    var camperSettingsErrorInfo: ErrorInfo? {
        let error = errors.first { error in
            if case .camperSettings = error {
                true
            } else {
                false
            }
        }

        switch error {
        case .camperSettings(let grouperError, let networkCall):
            return ErrorInfo(grouperError, networkCall)
        default:
            return nil
        }
    }

    var campReportFormatErrorInfo: ErrorInfo? {
        let error = errors.first { error in
            if case .campReportFormat = error {
                true
            } else {
                false
            }
        }

        switch error {
        case .campReportFormat(let grouperError, let networkCall):
            return ErrorInfo(grouperError, networkCall)
        default:
            return nil
        }
    }

    var campReportErrorInfo: ErrorInfo? {
        let error = errors.first { error in
            if case .campReport = error {
                true
            } else {
                false
            }
        }

        switch error {
        case .campReport(let grouperError, let networkCall):
            return ErrorInfo(grouperError, networkCall)
        default:
            return nil
        }
    }

    var selectedCamper: Camper? {
        camp?.campers.first(where: { camper in
            camper.id == groupingState?.camperCurrentlyBeingGrouped
        })
    }

    mutating
    func applyCamperSettings(for campID: Int, settings: [CamperSetting]) {
        camps = camps.map({ camp in
            if camp.info.eventNumber == campID {
                var updated = camp
                updated.campSettings?.campers = settings

                return updated
            } else {
                return camp
            }
        })
    }
}
