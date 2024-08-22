//
//  ContentView.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 3/21/24.
//

import Combine
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        VStack {
            switch coordinator.state.navigationMode {
            case .signin:
                SignInView()
                    .onAppear {
                        coordinator.send(event: .didBegin)
                    }
            case .camps:
                CampsView()
            case .report:
                ReportView()
            case .grouping:
                CamperGroupingView()
            }
            
            StatusMessagingView()
        }
    }
}

struct StatusMessagingView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        VStack {
            let messages = coordinator.state.statusMessages

            if messages.count < 10 {
                ForEach(messages, id: \.self) { message in
                    Text(message).font(.footnote)
                }
            } else {
                ScrollView {
                    VStack {
                        ForEach(messages, id: \.self) { message in
                            Text(message).font(.footnote)
                        }
                    }
                }.frame(height: 200)
            }
        }
    }
}

var GLOBAL_MESSAGES = [String: Any?]()

extension GrouperEventSpace.State {
    var statusMessages: [String] {
        var messages: [String] = []
        messages.append(contentsOf: errorStatusMessages)
        messages.append(contentsOf: fetchStatusMessages)
        messages.append(contentsOf: globalMessages)

        return messages
    }

    var errorStatusMessages: [String] {
        errors.map { error in
            switch error {
            case .signIn(let error, _):
                "􀀳 Signin error: \(error.status)"
            case .camps(let error, _):
                "􀀳 Get Cmps error: \(error.status)"
            case .groups(let error, _):
                "􀀳 Get Groups error: \(error.status)"
            case .campReports(let error, _):
                "􀀳 Get Camp Reports error: \(error.status)"
            case .campReport(let error, _):
                "􀀳 Get Camp Report error: \(error.status)"
            case .campReportFormat(let error, _):
                "􀀳 Get Camp Report Format error: \(error.status)"
            case .camperSettings(let error, _):
                "􀀳 Get Camper Settings error: \(error.status)"
            case .updateCampers(let error, _):
                "􀀳 Update Campers error: \(error.status)"
            case .setReport(let error, _):
                "􀀳 Set Report error: \(error.status)"
            case .updateReportFormat(let error, _):
                "􀀳 Update Report Format error: \(error.status)"
            case .uploadGroupAssignment(let camper, let group, let error, _):
                "􀀳 Upload Group Assignment of \(camper) into \(group) error: \(error.status)"
            case .markAssignmentAsUploaded(let camper, let group, let error, _):
                "􀀳 Mark Group Assignment of \(camper) into \(group) error: \(error.status)"
            }
        }
    }

    var fetchStatusMessages: [String] {
        activeFetches.map { networkCall in
            switch networkCall {
            case .signIn:
                "􀖇 signIn loading"
            case .camps:
                "􀖇 camps loading"
            case .groups:
                "􀖇 groups loading"
            case .campReports:
                "􀖇 campReports loading"
            case .campReport:
                "􀖇 campReport loading"
            case .campReportFormat:
                "􀖇 campReportFormat loading"
            case .camperSettings:
                "􀖇 camperSettings loading"
            case .setReport:
                "􀖇 setReport loading"
            case .updateReportFormat:
                "􀖇 updateReportFormat loading"
            case .setCamperAssigments:
                "􀖇 setCamperAssigments loading"
            case .uploadGroupAssignment(_):
                "􀖇 uploadGroupAssignment loading"
            case .markAssignmentAsUploaded(_):
                "􀖇 markAssignmentAsUploaded loading"
            }
        }
    }

    var globalMessages: [String] {
        GLOBAL_MESSAGES.compactMap { messageID, messageObject in
            messageObject.map { "􀅴 \(messageID): \(String(describing: $0))" }
        }
    }
}
