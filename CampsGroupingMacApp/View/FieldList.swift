//
//  FieldList.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 7/16/24.
//

import SwiftUI

struct FieldList: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>
    @State var reportFields: [ReportFieldSetting] = []
    @State var searchText = ""

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(reportFields.filter({ field in
                    isInSearchFilter(field: field)
                })) { field in
                    Toggle(isOn: enableBinding(for: field)) {
                        Text(field.fieldName)
                            .font(.footnote)
                            .lineLimit(5)
                    }
                }
            }.searchable(text: $searchText, prompt: "Search Fields")
        }
        .onAppear {
            reportFields = coordinator.state.currentReport?.fields ?? []
        }
        .onChange(of: coordinator.state) { oldValue, newValue in
            reportFields = newValue.currentReport?.fields ?? []
        }
    }

    func enableBinding(for field: ReportFieldSetting) -> Binding<Bool> {
        Binding {
            reportFields.first { fieldRef in
                fieldRef.fieldName == field.fieldName
            }?.visable ?? false
        } set: { newValue in
            reportFields = reportFields.map({ fieldRef in
                if fieldRef.fieldName == field.fieldName {
                    var newField = fieldRef
                    newField.visable = newValue
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

    func isInSearchFilter(field: ReportFieldSetting) -> Bool {
        guard !searchText.isEmpty else { return true }
        var index: String.Index?
        for char in searchText {
            if let firstIndex = field.fieldName.firstIndex(of: char) {
                if let current = index, firstIndex > current {
                    index = firstIndex
                } else if index == nil {
                    index = firstIndex
                } else {
                    return false
                }
            } else {
                return false
            }
        }

        return true
    }
}
