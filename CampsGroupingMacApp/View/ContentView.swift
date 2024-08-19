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
    }
}
