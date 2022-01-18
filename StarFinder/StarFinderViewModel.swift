import Foundation
import CoreLocation

struct DevicePosition {
  var latitude: Double
  var longitude: Double
  var altitude: Double
  var azimuth: Double
}

@MainActor
final class StarFinderViewModel: ObservableObject {
  private var initialCoordinate: CLLocationCoordinate2D?
  private var initialAltitude: Double?
  private var initialAzimuth: Double?

  private let locationManager = LocationManager()
  private let headingManager = MagneticHeadingManager()
  private let rollManager = RollManager()

  @Published private(set) var lastKnownPosition: DevicePosition?

  init() {
    startStreams()
  }

  private func startStreams() {
    Task.detached {
      for await rollRad in self.rollManager.stream {
        // TODO: convert to a normalized value... also, rate limit?
        let rollDeg = -rollRad * 180 / .pi - 90
        await self.updateAltitude(rollDeg)
      }
    }

    Task.detached {
      for await location in self.locationManager.stream {
        // TODO: convert to a normalized type... also, rate limit?
        await self.updateCoordinates(location)
      }
    }

    Task.detached {
      for await heading in self.headingManager.stream {
        // TODO: convert to a normalized value... also, rate limit?
        await self.updateAzimuth(heading)
      }
    }
  }

  private func updateCoordinates(_ coordinate: CLLocationCoordinate2D) {
    if var position = lastKnownPosition {
      position.latitude = coordinate.latitude
      position.longitude = coordinate.longitude
      lastKnownPosition = position
    } else {
      initialCoordinate = coordinate
      checkUpdatePosition()
    }
  }

  private func updateAzimuth(_ azimuth: Double) {
    if var position = lastKnownPosition {
      position.azimuth = azimuth
      lastKnownPosition = position
    } else {
      initialAzimuth = azimuth
      checkUpdatePosition()
    }
  }

  private func updateAltitude(_ altitude: Double) {
    if var position = lastKnownPosition {
      position.altitude = altitude
      lastKnownPosition = position
    } else {
      initialAltitude = altitude
      checkUpdatePosition()
    }
  }

  private func checkUpdatePosition() {
    if let coordinate = initialCoordinate,
       let azimuth = initialAzimuth,
       let altitude = initialAltitude {
      lastKnownPosition = DevicePosition(latitude: coordinate.latitude, longitude: coordinate.longitude, altitude: altitude, azimuth: azimuth)
    }
  }
}
