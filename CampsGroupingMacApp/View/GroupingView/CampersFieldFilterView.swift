import SwiftUI

struct CampersFieldFilterView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State private var filterMode: FieldFilterMode? = nil
    @State private var filterText = ""
    @State private var filterOptionSettings: [String: Bool] = [:]

    var filterOptions: [String] {
        filterOptionSettings.keys.sorted().compactMap { option in
            if let setting = filterOptionSettings[option], setting {
                option
            } else {
                nil
            }
        }
    }

    var body: some View {
        if let focus = coordinator.state.groupingState?.activeSelection {
            VStack {
                Text("Field Selected: " + focus.field.fieldName)
                HStack {
                    Button("Sort Accending") {
                        coordinator.send(
                            event: .grouping(event: .didSelectFieldSort(sortOrder: .forward))
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(
                        focus.sortOrder == .forward
                        ? Color(enum: .select)
                        : Color(enum: .plain)
                    )
                    Button("Sort Decending") {
                        coordinator.send(
                            event: .grouping(event: .didSelectFieldSort(sortOrder: .reverse))
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(
                        focus.sortOrder == .reverse
                        ? Color(enum: .select)
                        : Color(enum: .plain)
                    )
                }
                HStack {
                    Text("Filter:")
                    Spacer()
                }
                HStack {
                    Button("Select From Options") {
                        filterMode = .options
                        filterText = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(
                        filterMode == .options
                        ? Color(enum: .select)
                        : Color(enum: .plain)
                    )

                    Button("Enter Filter Query") {
                        filterMode = .query
                        clearFilter()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(
                        filterMode == .query
                        ? Color(enum: .select)
                        : Color(enum: .plain)
                    )
                }

                if let filterMode = filterMode {
                    switch filterMode {
                    case .query:
                        TextField("Filter By", text: $filterText)
                    case .options:
                        VStack {
                            let campers = coordinator.state.camp?.campers ?? []
                            let options = focus.field.optionsForCampers(campers)
                            if !options.isEmpty {
                                ScrollView {
                                    ForEach(options, id: \.self) { option in
                                        HStack {
                                            Spacer()
                                            let currentSetting = filterOptionSettings[option] ?? false
                                            Button(option) {
                                                filterOptionSettings[option] = !currentSetting
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(
                                                currentSetting
                                                ? Color(enum: .select)
                                                : Color(enum: .plain)
                                            )
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .onChange(
                of: coordinator.state.groupingState?.activeSelection
            ) { oldValue, newValue in
                let campers = coordinator.state.camp?.campers ?? []
                let options = focus.field.optionsForCampers(campers)
                if oldValue?.field != newValue?.field {
                    clearFilter()
                }
            }
            .onChange(of: filterMode, { oldValue, newValue in
                clearFilter()
            })
            .onChange(of: filterOptionSettings, { oldValue, newValue in
                coordinator.send(
                    event: .grouping(
                        event: .didSetFilterOptionsForReportFieldSetting(
                            filterOptions: filterOptions
                        )
                    )
                )
            })
            .onChange(of: filterText) { oldValue, newValue in
                if oldValue != newValue {
                    coordinator.send(
                        event: .grouping(
                            event: .didSetFilterForReportFieldSetting(filterText: newValue)
                        )
                    )
                }
            }
        }
    }

    func clearFilter() {
        filterText = ""
        filterOptionSettings = [:]
        coordinator.send(
            event: .grouping(
                event: .didSetFilterForReportFieldSetting(filterText: "")
            )
        )
    }
}

enum FieldFilterMode {
    case query, options
}
