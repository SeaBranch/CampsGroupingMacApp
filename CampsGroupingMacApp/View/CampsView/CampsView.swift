import SwiftUI

struct CampsView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        if coordinator.state.isPerformingCampsCall {
            ProgressView {
                Text("loading camps")
            }
        } else {
            NavigationSplitView {
                CampsNavView()
            } content: {
                CampsContentView()
            } detail: {
                CampsDetailView()
            }
        }
    }
}

#Preview {
    CampsView().environment(EventCoordinator<GrouperEventSpace>(state: GrouperState()))
}
