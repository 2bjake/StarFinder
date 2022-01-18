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

  @Published private(set) var lastKnownPosition: DevicePosition?


  init() {
    //temp
    initialAltitude = 0
    initialCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    initialAzimuth = 0

    Task.detached {
      for await roll in RollManager.stream {
        // TODO: convert to a normalized value... also, rate limit?
        await self.updateAltitude(roll)
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

  func updateCoordinates(_ coordinate: CLLocationCoordinate2D) {
    if var position = lastKnownPosition {
      position.latitude = coordinate.latitude
      position.longitude = coordinate.longitude
      lastKnownPosition = position
    } else {
      initialCoordinate = coordinate
      checkUpdatePosition()
    }
  }

  func updateAzimuth(_ azimuth: Double) {
    if var position = lastKnownPosition {
      position.azimuth = azimuth
      lastKnownPosition = position
    } else {
      initialAzimuth = azimuth
      checkUpdatePosition()
    }
  }

  func updateAltitude(_ altitude: Double) {
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
