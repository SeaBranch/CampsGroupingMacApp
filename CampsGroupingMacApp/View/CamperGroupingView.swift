import SwiftUI

struct CamperGroupingView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        NavigationSplitView {
            CampersToBeGroupedView()
        } content: {
            CamperAndGroupSearchView()
        } detail: {
            CampersAndGroupsDetailView()
        }
    }
}
