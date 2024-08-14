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

    var body: some View {
        if let scope = coordinator.state.campScope,
           let camp = coordinator.state.camp,
           let campSettings = camp.campSettings,
           let report = camp.report {
            reportNavStack(report: report, camp: camp.info, scope: scope)
                .onAppear {
//                    reportFields = report.reportFieldSettings.filter({ field in
//                        field.visable
//                    })
                }
                .onChange(of: coordinator.state) { oldValue, newValue in
//                    reportFields = newValue.camp?.campSettings?.report.reportFieldSettings.filter({ field in
//                        field.visable
//                    }) ?? []
                }
        } else {
            Text("No Report Found")
        }
    }

    @ViewBuilder
    func reportNavStack(report: Report, camp: CampInfo, scope: CampsScope) -> some View {
        NavigationSplitView {
            FieldList()
        } content: {
            selectedFieldList(camp: camp, scope: scope)
        } detail: {
//            if let field = coordinator.state.fieldTypeFieldBeingChanged {
//                fieldTypingList(for: field)
//            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("< \(camp.title)") {
                    coordinator.send(event: .menu(event: .didGoBackToCamps(scope: scope)))
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
    func selectedFieldList(camp: CampInfo, scope: CampsScope) -> some View {
        List {
            Button("Begin Grouping") {
                //self.beginGrouping(camp: camp, scope: scope)
            }

            ForEach(reportFields) { field in
                fieldView(for: field)
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
    func fieldView(for field: ReportFieldSetting) -> some View {
        VStack(alignment: .leading) {
            Text(field.fieldName)
            Toggle(isOn: handleBinding(for: field)) {
                Text("Handle Directly")
            }
            Button("Type: \(field.fieldType.rawValue)") {
                // TODO: .didSelectFieldTypeButtonForField(field)))
            }
            Text("equivelent to: \(field.equivalance)")
            Toggle(isOn: useBinding(for: field)) {
                Text("Use to Group")
            }
            Toggle(isOn: showInTableBinding(for: field)) {
                Text("View In Table")
            }
        }
    }

    func handleBinding(for field: ReportFieldSetting) -> Binding<Bool> {
        Binding {
            reportFields.first { fieldRef in
                fieldRef.fieldName == field.fieldName
            }?.handleDirectly ?? false
        } set: { newValue in
            reportFields = reportFields.map({ fieldRef in
                if fieldRef.fieldName == field.fieldName {
                    var newField = fieldRef
                    newField.handleDirectly = newValue
                    DispatchQueue.main.async {
                        coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(newField))))
                    }

                    return newField
                }

                return fieldRef
            })
        }

    }

    func useBinding(for field: ReportFieldSetting) -> Binding<Bool> {
        Binding {
            reportFields.first { fieldRef in
                fieldRef.fieldName == field.fieldName
            }?.includeInGrouping ?? false
        } set: { newValue in
            reportFields = reportFields.map({ fieldRef in
                if fieldRef.fieldName == field.fieldName {
                    var newField = fieldRef
                    newField.includeInGrouping = newValue

                    DispatchQueue.main.async {
                        coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(newField))))
                    }
                    return newField
                }

                return fieldRef
            })
        }

    }

    func showInTableBinding(for field: ReportFieldSetting) -> Binding<Bool> {
        Binding {
            reportFields.first { fieldRef in
                fieldRef.fieldName == field.fieldName
            }?.showInTable ?? false
        } set: { newValue in
            reportFields = reportFields.map({ fieldRef in
                if fieldRef.fieldName == field.fieldName {
                    var newField = fieldRef
                    newField.showInTable = newValue

                    DispatchQueue.main.async {
                        coordinator.send(event: .camp(event: .reportEvent(event: .didChangeReportFieldSetting(newField))))
                    }
                    return newField
                }

                return fieldRef
            })
        }

    }
}
