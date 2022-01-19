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

  private var locationTask: Task<Void, Never>?
  private var headingTask: Task<Void, Never>?
  private var rollTask: Task<Void, Never>?

  private var isTracking = false

  @Published private(set) var lastKnownPosition: DevicePosition?

  init() { }

  func startTracking() {
    guard !isTracking else { return }
    isTracking = true

    let rollManager = RollManager()
    rollTask = Task.detached {
      for await rollRad in rollManager.makeStream() {
        // TODO: convert to a normalized value... also, rate limit?
        let rollDeg = -rollRad * 180 / .pi - 90
        await self.updateAltitude(rollDeg)
      }
    }

    let locationManager = LocationManager()
    locationTask = Task.detached {
      for await location in locationManager.makeStream() {
        // TODO: convert to a normalized type... also, rate limit?
        await self.updateCoordinates(location)
      }
    }

    let headingManager = MagneticHeadingManager()
    headingTask = Task.detached {
      for await heading in headingManager.makeStream() {
        // TODO: convert to a normalized value... also, rate limit?
        await self.updateAzimuth(heading)
      }
    }
  }

  func stopTracking() {
    guard isTracking else { return }
    isTracking = false

    locationTask?.cancel()
    locationTask = nil

    headingTask?.cancel()
    headingTask = nil

    rollTask?.cancel()
    rollTask = nil
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
