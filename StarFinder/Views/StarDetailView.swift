import SwiftUI
import CoreLocation
import StarCoordinates

extension Double {
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

  return "\(isNegative ? "-" : "+")\(degrees)° \(minutes)' \(seconds.formatted(.number.precision(.significantDigits(2))))\""
}

struct StarDetailView: View {
  @StateObject private var viewModel = StarFinderViewModel() // TODO: make version that just captures lat/long

  let star: Star

  var raString: String {
    let ra = star.coordinates.rightAscension
    return "\(ra.hours)h \(ra.minutes)m \(ra.seconds.formattedToHundredth)s"
  }

  var decString: String {
    degreesMinutesSecondsString(star.coordinates.declination.degrees)
  }

  var location: CLLocationCoordinate2D? {
    guard let position = viewModel.lastKnownPosition else { return nil }
    return CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
  }

  var horizontalCoordinates: HorizontalCoordinates? {
    guard let location = location else { return nil }
    return .init(coordinates: star.coordinates, location: location, date: .now)
  }

  var body: some View {
    List {
      Section("Coordinates") {
        Text("Right ascension: " + raString)
        Text("Declination: " + decString)
        if let coords = horizontalCoordinates {
          Text("Azimuth: " + degreesMinutesSecondsString(coords.azimuthDeg))
          Text("Altitude: " + degreesMinutesSecondsString(coords.altitudeDeg))
          NavigationLink("Find") {
            StarFinderView(target: coords)
          }

        }
      }
      .listStyle(InsetGroupedListStyle())
      .navigationTitle(star.name)
      .onAppear { viewModel.startTracking() }
      .onDisappear { viewModel.stopTracking() }
    }
  }
}

struct StarDetailViefw_Previews: PreviewProvider {
  static var previews: some View {
    StarDetailView(star : .example)
  }
}
