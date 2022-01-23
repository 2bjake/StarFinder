import SwiftUI
import StarCoordinates

private extension StarCoordinates.Angle.DMS {
  var displayString: String {
    "\(degrees > 0 ? "+" : "")\(degrees)° \(minutes)' \(seconds.formattedToTenth)\""
  }
}

private extension RightAscension {
  var displayString: String {
    "\(hours)h \(minutes)m \(seconds.formattedToHundredth)s"
  }
}

struct StarDetailView: View {
  @StateObject private var viewModel = StarDetailViewModel()
  @State private var horizontalCoordinates: HorizontalCoordinates?

  let timer = Timer.publish(every: 1, tolerance: 0, on: .main, in: .common)
    .autoconnect()
    .map { _ in () }

  let star: Star

  var raString: String {
    let ra = star.coordinates.rightAscension
    return "\(ra.hours)h \(ra.minutes)m \(ra.seconds.formattedToHundredth)s"
  }

  var body: some View {
    List {
      Section("Coordinates") {
        Text("Right ascension: " + raString)

        Text("Declination: " + star.coordinates.declination.dms.displayString)

        if let location = viewModel.lastKnownLocation, let coords = horizontalCoordinates {
          Text("Azimuth: " + coords.azimuth.dms.displayString)
          Text("Altitude: " + coords.altitude.dms.displayString)

          NavigationLink("Find") {
            StarFinderView(equatorialCoords: star.coordinates, initialLocation: location)
          }
        }
      }
      .listStyle(InsetGroupedListStyle())
      .navigationTitle(star.name)
      .onReceive(timer, perform: updateCoordinates)
      .onAppear { viewModel.startTracking() }
      .onDisappear { viewModel.stopTracking() }
    }
  }

  private func updateCoordinates() {
    guard let location = viewModel.lastKnownLocation else { return }
    horizontalCoordinates = .init(coordinates: star.coordinates, location: location, date: .now)
  }
}

struct StarDetailViefw_Previews: PreviewProvider {
  static var previews: some View {
    StarDetailView(star : .example)
  }
}
