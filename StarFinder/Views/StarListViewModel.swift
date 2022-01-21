import StarCoordinates
import Foundation

@MainActor
class StarListViewModel: ObservableObject {
  let stars =  [
    Star(name: "Sirius", coordinates: EquatorialCoordinates(
      rightAscension: .init(hours: 6, minutes: 45, seconds: 8.92),
      declination: .init(degrees: -16, minutes: 42, seconds: 58.0))),

    Star(name: "Polaris", coordinates: EquatorialCoordinates(
      rightAscension: .init(hours: 2, minutes: 31, seconds: 49.06),
      declination: .init(degrees: 89, minutes: 15, seconds: 50.8)))
  ]
}
