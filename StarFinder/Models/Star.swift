import StarCoordinates

struct Star {
  let name: String
  let coordinates: EquatorialCoordinates
}

extension Star {
  static var example: Star { Star(name: "Sirius", coordinates: EquatorialCoordinates(rightAscension: .init(hours: 6, minutes: 45, seconds: 8.92), declination: .init(degrees: -16, minutes: 42, seconds: 58.0))) }
}
