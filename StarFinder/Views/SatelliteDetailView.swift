import SwiftUI
import StarCoordinates

private extension StarCoordinates.Angle.DMS {
  var displayString: String {
    "\(degrees > 0 ? "+" : "")\(degrees)° \(minutes)' \(seconds.formattedToTenth)\""
  }
}

struct SatelliteDetailView: View {
  @StateObject private var viewModel = StarDetailViewModel()
  @State private var horizontalCoordinates: HorizontalCoordinates?

  let timer = Timer.publish(every: 1, tolerance: 0, on: .main, in: .common)
    .autoconnect()
    .map { _ in () }

  let satellite: Satellite

  var body: some View {
    List {
      Section("Coordinates") {
        if let location = viewModel.lastKnownLocation, let coords = horizontalCoordinates {
          Text("Azimuth: " + coords.azimuth.dms.displayString)
          Text("Altitude: " + coords.altitude.dms.displayString)

          NavigationLink("Find") {
            StarFinderView(target: .tle(satellite.tle), initialLocation: location)
          }
        }
      }
      .listStyle(InsetGroupedListStyle())
      .navigationTitle(satellite.name)
      .onReceive(timer, perform: updateCoordinates)
      .onAppear { viewModel.startTracking() }
      .onDisappear { viewModel.stopTracking() }
    }
  }

  private func updateCoordinates() {
    guard let location = viewModel.lastKnownLocation else { return }
    horizontalCoordinates = .init(tle: satellite.tle, location: location)
  }
}

struct SatelliteDetailViefw_Previews: PreviewProvider {
  static var previews: some View {
    StarDetailView(star : .example)
  }
}
