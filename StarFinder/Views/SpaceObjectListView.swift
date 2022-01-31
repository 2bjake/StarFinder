import SwiftUI

struct SpaceObjectListView: View {
  @StateObject var viewModel = SpaceObjectListViewModel()
  var body: some View {
    NavigationView {
      List {
        ForEach(viewModel.stars, id: \.name) { star in
          NavigationLink(star.name) {
            StarDetailView(star: star)
          }
        }
        ForEach(viewModel.satellites, id: \.name) { satellite in
          NavigationLink(satellite.name) {
            SatelliteDetailView(satellite: satellite)
          }
        }
      }
      .navigationTitle("Space Finder")
    }
  }
}

struct SpaceObjectListView_Previews: PreviewProvider {
  static var previews: some View {
    SpaceObjectListView()
  }
}
