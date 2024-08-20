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
            case .signIn(let error, let networkCall):
                "􀀳 Signin error: \(error.status)"
            case .camps(let error, let networkCall):
                "􀀳 Get Cmps error: \(error.status)"
            case .groups(let error, let networkCall):
                "􀀳 Get Groups error: \(error.status)"
            case .campReports(let error, let networkCall):
                "􀀳 Get Camp Reports error: \(error.status)"
            case .campReport(let error, let networkCall):
                "􀀳 Get Camp Report error: \(error.status)"
            case .campReportFormat(let error, let networkCall):
                "􀀳 Get Camp Report Format error: \(error.status)"
            case .camperSettings(let error, let networkCall):
                "􀀳 Get Camper Settings error: \(error.status)"
            case .updateCampers(let error, let networkCall):
                "􀀳 Update Campers error: \(error.status)"
            case .setReport(let error, let networkCall):
                "􀀳 Set Report error: \(error.status)"
            case .updateReportFormat(let error, let networkCall):
                "􀀳 Update Report Format error: \(error.status)"
            }
        }
    }

    var fetchStatusMessages: [String] {
        activeFetches.map { networkCall in
            switch networkCall {
            case .signIn(let uUID):
                "􀖇 signIn loading"
            case .camps(let uUID):
                "􀖇 camps loading"
            case .groups(let uUID):
                "􀖇 groups loading"
            case .campReports(let uUID):
                "􀖇 campReports loading"
            case .campReport(let uUID):
                "􀖇 campReport loading"
            case .campReportFormat(let uUID):
                "􀖇 campReportFormat loading"
            case .camperSettings(let uUID):
                "􀖇 camperSettings loading"
            case .setReport(let uUID):
                "􀖇 setReport loading"
            case .updateReportFormat(let uUID):
                "􀖇 updateReportFormat loading"
            case .setCamperAssigments(let uUID):
                "􀖇 setCamperAssigments loading"
            }
        }
    }

    var globalMessages: [String] {
        GLOBAL_MESSAGES.compactMap { messageID, messageObject in
            messageObject.map { "􀅴 \(messageID): \(String(describing: $0))" }
        }
    }
}
