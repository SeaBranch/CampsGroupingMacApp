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

    @State var reportFields: [ReportField] = []
    @State var fieldForTypeChange: ReportField?

    var body: some View {
        if case .report(let possibleReport, let camp, let scope) = coordinator.state.navigationMode, let report = possibleReport {
            HStack {
                reportNavStack(report: report, camp: camp, scope: scope)
                    .onAppear {
                        reportFields = report.fields.filter({ field in
                            field.visable
                        })
                    }
                    .onChange(of: coordinator.state) { oldValue, newValue in
                        reportFields = newValue.report?.fields.filter({ field in
                            field.visable
                        }) ?? []
                    }

                FieldList().frame(width: 300)
            }
        } else {
            Text("No Report Found")
        }
    }

    @ViewBuilder
    func reportNavStack(report: Report, camp: Camp, scope: CampsScope) -> some View {
        NavigationSplitView {
            List {
                ForEach(reportFields) { field in
                    fieldView(for: field)
                }
            }
        } content: {
            Text("Rows")
        } detail: {
            Text("compare")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("< \(camp.title)") {
                    coordinator.send(event: .menu(event: .didGoBackToCamps(scope: scope)))
                }
            }
        }

    }

    @ViewBuilder
    func fieldView(for field: ReportField) -> some View {
        VStack(alignment: .leading) {
            Text(field.fieldName)
            Toggle(isOn: handleBinding(for: field)) {
                Text("Handle Directly")
            }
            Button("Type: \(field.fieldType.rawValue)") {
                fieldForTypeChange = field
            }
            .confirmationDialog(
                "Set Data Type",
                isPresented: typeSetBinding()) {
                    ForEach(ReportFieldType.allCases) { dataType in
                        Button(dataType.rawValue) {
                            reportFields = reportFields.map({ oldField in
                                if oldField.fieldName == field.fieldName {
                                    var newField = oldField
                                    newField.fieldType = dataType
                                    coordinator.send(event: .camp(event: .didChangeField(newField)))

                                    return newField
                                } else {
                                    return oldField
                                }
                            })
                        }
                    }
                }
            Text("equivelent to: \(field.equivalance)")
            Toggle(isOn: useBinding(for: field)) {
                Text("Use to Group")
            }
        }
    }

    func typeSetBinding() -> Binding<Bool> {
        Binding {
            fieldForTypeChange != nil
        } set: { newValue in
            if !newValue {
                fieldForTypeChange = nil
            }
        }
    }

    func handleBinding(for field: ReportField) -> Binding<Bool> {
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
                        coordinator.send(
                            event: .camp(
                                event: .didChangeField(newField)
                            )
                        )
                    }

                    return newField
                }

                return fieldRef
            })
        }

    }

    func useBinding(for field: ReportField) -> Binding<Bool> {
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
                        coordinator.send(
                            event: .camp(
                                event: .didChangeField(newField)
                            )
                        )
                    }
                    return newField
                }

                return fieldRef
            })
        }

    }
}
