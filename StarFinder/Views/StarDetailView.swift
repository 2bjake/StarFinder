import SwiftUI
import CoreLocation
import StarCoordinates

extension Double {
  var formattedToTenth: String {
    String(format: "%.01f", self)
  }

  var formattedToHundredth: String {
    String(format: "%.02f", self)
  }
}

func degreesMinutesSecondsString(_ angle: Double) -> String{
  let isNegative = angle < 0
  let degrees = Int(abs(angle))
  let remainder = abs(angle) - Double(degrees)
  let minutes = Int(remainder * 60)
  let seconds = (remainder - Double(minutes) / 60) * 3600

  return "\(isNegative ? "-" : "+")\(degrees)° \(minutes)' \(seconds.formattedToTenth)\""
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

  var decString: String {
    degreesMinutesSecondsString(star.coordinates.declination.degrees)
  }

  var body: some View {
    List {
      Section("Coordinates") {
        Text("Right ascension: " + raString)

        Text("Declination: " + decString)

        if let location = viewModel.lastKnownLocation, let coords = horizontalCoordinates {
          Text("Azimuth: " + degreesMinutesSecondsString(coords.azimuthDeg))
          Text("Altitude: " + degreesMinutesSecondsString(coords.altitudeDeg))

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
