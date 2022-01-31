import StarCoordinates
import Foundation

@MainActor
class SpaceObjectListViewModel: ObservableObject {
  let stars =  [
    Star(name: "Sirius", coordinates: EquatorialCoordinates(
      rightAscension: .init(hours: 6, minutes: 45, seconds: 8.92),
      declination: .init(degrees: -16, minutes: 42, seconds: 58.0))),

    Star(name: "Polaris", coordinates: EquatorialCoordinates(
      rightAscension: .init(hours: 2, minutes: 31, seconds: 49.06),
      declination: .init(degrees: 89, minutes: 15, seconds: 50.8)))
  ]

  let satellites = [
    Satellite(name: "ISS", tle: TwoLineElement(
      name: "ISS",
      lineOne: "1 25544U 98067A   22030.51179398  .00005765  00000+0  11002-3 0  9999",
      lineTwo: "2 25544  51.6444 298.3935 0006761  77.9892 281.4353 15.49702707323823")!)
  ]
}
