//
//  ReportView.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/16/24.
//

import SwiftUI

struct ReportView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State var reportFields: [ReportFieldSetting] = []
    @State var fieldFilter = ""

    @State var selectedField: String?

    var body: some View {
        if let scope = coordinator.state.campScope,
           let camp = coordinator.state.camp,
           let campSettings = camp.campSettings,
           let report = camp.report {
            reportNavStack(report: report, camp: camp.info, scope: scope)
                .onAppear {
                    updateFields(campSettings: campSettings, report: report)
                }
                .onChange(of: coordinator.state) { oldValue, newValue in
                    if let campSettings = newValue.camp?.campSettings {
                        updateFields(campSettings: campSettings, report: report)
                    }
                }
        } else {
            noReportView()
        }
    }

    func updateFields(campSettings: CampSettings, report: Report) {
        DispatchQueue.processing.async {
            let settings = coordinator.state.currentFields.filter { field in
                field.visable
            }
            DispatchQueue.main.async {
                self.reportFields = settings.sortedByFieldName
            }
        }
    }

    @ViewBuilder
    func noReportView() -> some View {
        if coordinator.state.isPerformingCampReportCall {
            ProgressView {
                Text("Loading Report")
            }
        } else {
            NavigationStack {
                Text("No Report Found")
            }.toolbar {
                Button("Back") {
                    coordinator.send(event: .menu(event: .didGoBackToCamps(scope: coordinator.state.campScope ?? .sandbox)))
                }
            }
            .toolbar(.visible, for: .automatic)
        }
    }

    @ViewBuilder
    func reportNavStack(report: Report, camp: CampInfo, scope: CampsScope) -> some View {
        NavigationSplitView {
            FieldList()
        } content: {
            visibleFieldList(camp: camp, scope: scope)
        } detail: {
            VStack {
                if let fieldName = selectedField, let field = reportFields.first(where: { setting in
                    setting.fieldName == fieldName
                }) {
                    fieldView(for: field)
                }
                Spacer()
                Rectangle().fill(.primary).frame(height: 1)
                Button {
                    if let camp = coordinator.state.camp {
                        coordinator.send(event: .camp(event: .didSelectViewGrouping(camp: camp)))
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Begin Grouping")
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("< \(camp.title)") {
                    coordinator.send(event: .menu(event: .didGoBackToCamps(scope: scope)))
                }
            }
            ToolbarItem(placement: .navigation) {
                Button("Save changes") {
                    coordinator.send(event: .menu(event: .didSelectSave(.report)))
                }
            }
        }
    }

    /*
    func beginGrouping(camp: CampInfo, scope: CampsScope) {
        guard let campers = coordinator
            .state
            .currentReport?
            .asCamperRows(existingCampers: coordinator.state.campers.map(\.camper))
        else {
            return
        }

        guard !campers.isEmpty else { return }

        coordinator.send(
            event: .camp(
                event: .didSelectBeginGrouping(
                    campers: campers,
                    camp: camp,
                    scope: scope
                )
            )
        )
    }
*/
    @ViewBuilder
    func visibleFieldList(camp: CampInfo, scope: CampsScope) -> some View {
        List {
            Button("Begin Grouping") {
                //self.beginGrouping(camp: camp, scope: scope)
            }

            ForEach(reportFields) { field in
                fieldRow(for: field)
            }
        }
    }

    @ViewBuilder
    func fieldTypingList(for field: ReportFieldSetting) -> some View {
        List {
            ForEach(ReportFieldType.allCases) { type in
                Button(type.rawValue) {
                    var newField = field
                    newField.fieldType = type
                    coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(newField))))
                }
            }
        }
    }


    @ViewBuilder
    func fieldRow(for field: ReportFieldSetting) -> some View {
        Button {
            selectedField = field.fieldName
        } label: {
            VStack(alignment: .leading) {
                Text(field.fieldName).font(.title)
                Text("Type: \(field.fieldType.rawValue)").font(.footnote)
            }
        }
    }


    @ViewBuilder
    func fieldView(for field: ReportFieldSetting) -> some View {
        VStack(alignment: .leading) {
            Text(field.fieldName).font(.largeTitle)

            Button("Use to Group: \(field.includeInGrouping)") {
                if var updated = reportFields.first(where: { fieldRef in
                    fieldRef.fieldName == field.fieldName
                }) {
                    updated.includeInGrouping.toggle()
                    coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(updated))))
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(field.includeInGrouping ? .accentColor : .white)

            Button("View In Table: \(field.showInTable)") {
                if var updated = reportFields.first(where: { fieldRef in
                    fieldRef.fieldName == field.fieldName
                }) {
                    updated.showInTable.toggle()
                    coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(updated))))
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(field.showInTable ? .accentColor : .white)

            Button("Flagged for handling: \(field.handleDirectly)") {
                if var updated = reportFields.first(where: { fieldRef in
                    fieldRef.fieldName == field.fieldName
                }) {
                    updated.handleDirectly.toggle()
                    coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(updated))))
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(field.handleDirectly ? .accentColor : .white)

            Button("Primary For Camper: \(field.isRegistrantData)") {
                if var updated = reportFields.first(where: { fieldRef in
                    fieldRef.fieldName == field.fieldName
                }) {
                    updated.isRegistrantData.toggle()
                    coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(updated))))
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(field.isRegistrantData ? .accentColor : .white)

            Text("Type:")
            ForEach(ReportFieldType.allCases) { type in
                Button("\(type.displayName)") {
                    if var updated = reportFields.first(where: { fieldRef in
                        fieldRef.fieldName == field.fieldName
                    }),
                       field.fieldType != type {
                        updated.fieldType = type
                        coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(updated))))
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(field.fieldType == type ? .accentColor : .white)
                .padding(.leading)
            }
        }
    }
}
