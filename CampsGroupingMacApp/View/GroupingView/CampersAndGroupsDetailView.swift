import SwiftUI

struct CampersAndGroupsDetailView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        VStack {
            Spacer()
            Spacer()
            CampersFieldFilterView()
            Spacer()
        }
    }
}

struct CampersFieldFilterView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    @State private var filterText = ""

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

                TextField("Filter By", text: $filterText)
            }
            .padding()
            .onChange(
                of: coordinator.state.groupingState?.activeSelection
            ) { oldValue, newValue in
                if oldValue?.field != newValue?.field {
                    filterText = ""
                }
            }
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
}
