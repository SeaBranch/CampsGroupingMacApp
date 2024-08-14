import SwiftUI

struct CamperAndGroupSearchView: View {
    @State private var searchQuery = ""

    var body: some View {
        NavigationStack {
            Text("Search for a camper or group")
        }
        .searchable(text: $searchQuery, placement: .sidebar)
    }
}
