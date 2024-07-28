//
//  SignInActionHandler.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 6/3/24.
//

import Foundation

class NetworkActionHandler: ActionHandler<GrouperEventSpace> {
    let signInLogicController: SignInLogicControllerProtocol
    let getCampsLogicController: GetCampsLogicControllerProtocol

    init(
        signInLogicController: SignInLogicControllerProtocol = SignInLogicController(),
        getCampsLogicController: GetCampsLogicControllerProtocol = GetCampsLogicController()
    ) {
        self.signInLogicController = signInLogicController
        self.getCampsLogicController = getCampsLogicController
    }

    override func handle(action: GrouperEventSpace.Action, handleEvent: @escaping (GrouperEventSpace.Event) -> Void) {
        switch action {
        case .signIn(let email, let password, let scope, let fetchID):
            signInLogicController.signIn(email: email, password: password, scope: scope) { result in
                handleEvent(
                    .api(event: .didRespondToSignIn(result: result, scope: scope, fetchID: fetchID))
                )
            }
        case .getCamps(let account, let scope, let fetchID):
            getCampsLogicController.getCamps(account: account, scope: scope) { result in
                handleEvent(
                    .api(
                        event: .didRespondToGetCamps(
                            result: result,
                            account: account, 
                            scope: scope,
                            fetchID: fetchID
                        )
                    )
                )
            }
        case .updateReportFormatWithField(let report, let field):
            DispatchQueue.processing.async {
                let updatedReport = report.withChangedField(field)
                // TODO: sync format change

                DispatchQueue.main.async {
                    handleEvent(.camp(event: .didUpdateReport(updatedReport)))
                }
            }
        case .getCampReport(let camp, let scope):
            camp.reportID?.getReport() { result in
                if case .success(let report) = result {
                    handleEvent(
                        .camp(
                            event: .didGetReportForCamp(
                                report: report,
                                camp: camp,
                                scope: scope
                            )
                        )
                    )
                }
            }
        case .getReportFormatForCamp(let camp, let report):

            // TODO: get format from service

            // Placeholder Logic
            DispatchQueue.processing.async {
                var updatedReport = report
                updatedReport.fields = report.fields.map {
                    $0.setPlaceholderFormat()
                }
                updatedReport.fields.forEach { field in
                    updatedReport = updatedReport.withChangedField(field)
                }

                DispatchQueue.main.async {
                    handleEvent(.camp(event: .didUpdateReport(report)))
                }
            }
            // end Placeholder Logic
        }
    }
}

extension DispatchQueue {
    static let processing = DispatchQueue(label: "processing", qos: .background)
}

extension ReportField {
    func setPlaceholderFormat() -> ReportField {
        var updatedField = self
        switch fieldName {
        case "Attendee Number":
            updatedField.fieldType = .camperID
            updatedField.visable = true
            updatedField.showInTable = true
            updatedField.includeInGrouping = true
        case "Grouping Tool Group",
            "How old will the son be while at Father Son Camp?",
            "Group Attendee Count":
            updatedField.fieldType = .int
            updatedField.visable = true
            updatedField.includeInGrouping = true
        case "Full Address (PostalCode)":
            updatedField.fieldType = .zip
            updatedField.visable = true
            updatedField.includeInGrouping = true
        case "Group Number":
            updatedField.fieldType = .groupID
            updatedField.visable = true
            updatedField.showInTable = true
            updatedField.includeInGrouping = true
        case "Father (Figure) Full Name (Combined)":
            updatedField.fieldType = .fullName
            updatedField.visable = true
            updatedField.showInTable = true
            updatedField.includeInGrouping = true
        case "Father (Figure) Full Name (First)",
            "Father (Figure) Full Name (Last)",
            "Son's Full Name (First)",
            "Son's Full Name (Last)":
            updatedField.fieldType = .partOfName
            updatedField.visable = true
            updatedField.includeInGrouping = true
        case "If Crossroads is your church which site do you associate with?":
            updatedField.fieldType = .crossroadsSite
            updatedField.visable = true
            updatedField.showInTable = true
            updatedField.includeInGrouping = true

        case "Son's Full Name (Combined)":
            updatedField.visable = true
            updatedField.handleDirectly = true
            updatedField.showInTable = true
            updatedField.includeInGrouping = true

        case "Full Address (Combined)",
            "Full Address (Street1)",
            "Full Address (Street2)",
            "Full Address (City)",
            "Full Address (Region)",
            "Full Address (Country)",
            "Full Address (CountryName)",
            "Full Address (RegionName)",
            "Phone Number",
            "Can we text you?",
            "Email",
            "Father's Birthdate",
            "Son's Birthdate",
            "Father's marital status?",
            "What are the ages of Father's kid(s)? (check all that apply...even those not attending this camp)",
            "What church are you connected with?",
            "How should we prioritize grouping you?",
            "Group Id",
            "Group Name",
            "Group Type",
            "Group Email":
            updatedField.visable = true
            updatedField.handleDirectly = true
            updatedField.includeInGrouping = true

        case "Father 1 Preference (First)",
            "Father 1 Preference (Last)",
            "Son 1 Preference (First)",
            "Son 1 Preference (Last)",
            "Father 2 Preference (First)",
            "Father 2 Preference (Last)",
            "Son 2 Preference (First)",
            "Son 2 Preference (Last)":

            updatedField.fieldType = .partOfName
            updatedField.visable = true
            updatedField.handleDirectly = true
            updatedField.includeInGrouping = true

        default:
            return self
        }

        return updatedField
    }
}
