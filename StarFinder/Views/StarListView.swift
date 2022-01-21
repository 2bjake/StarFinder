import SwiftUI

struct StarListView: View {
  @StateObject var viewModel = StarListViewModel()
  var body: some View {
    NavigationView {
      List {
        ForEach(viewModel.stars, id: \.name) { star in
          NavigationLink(star.name) {
            StarDetailView(star: star)
          }
        }
      }
      .navigationTitle("Star Finder")
    }
  }
}

struct StarListView_Previews: PreviewProvider {
  static var previews: some View {
    StarListView()
  }
}
