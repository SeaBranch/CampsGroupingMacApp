import SwiftUI

struct CampersAndGroupsDetailView: View {
    @EnvironmentObject var coordinator: EventCoordinator<GrouperEventSpace>

    var body: some View {
        VStack {
            CamperSelectionDetailView()
            Spacer().frame(height: 16)
            PotientialMatchDetailView()
            Spacer()
            CampersFieldFilterView()
            Spacer().frame(height: 20)
        }
    }
}
