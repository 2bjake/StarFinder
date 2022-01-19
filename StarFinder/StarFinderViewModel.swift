import Foundation
import CoreLocation

// All values are in degrees
struct DevicePosition {
  var latitude: Double
  var longitude: Double
  var altitude: Double
  var azimuth: Double
}

@MainActor
final class StarFinderViewModel: ObservableObject {
  private var partialPosition = PartialPosition()

  private var locationTask: Task<Void, Never>?
  private var headingTask: Task<Void, Never>?
  private var altitudeTask: Task<Void, Never>?

  private var isTracking = false

  @Published private(set) var lastKnownPosition: DevicePosition?

  init() { }

  func startTracking() {
    guard !isTracking else { return }
    isTracking = true

    let altitudeManager = AltitudeManager()
    altitudeTask = Task.detached { [weak self] in
      for await altitude in altitudeManager.makeStream() {
        await self?.updateAltitude(altitude)
      }
    }

    let locationManager = LocationManager()
    locationTask = Task.detached { [weak self] in
      for await location in locationManager.makeStream() {
        await self?.updateCoordinate(location)
      }
    }

    let headingManager = MagneticHeadingManager()
    headingTask = Task.detached { [weak self] in
      for await heading in headingManager.makeStream() {
        await self?.updateAzimuth(heading)
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

    altitudeTask?.cancel()
    altitudeTask = nil
  }

  deinit {
    locationTask?.cancel()
    headingTask?.cancel()
    altitudeTask?.cancel()
  }

  private func updateCoordinate(_ coordinate: CLLocationCoordinate2D) {
    if lastKnownPosition == nil {
      partialPosition.coordinate = coordinate
      lastKnownPosition = partialPosition.attemptPositionCreation()
    } else {
      lastKnownPosition?.latitude = coordinate.latitude
      lastKnownPosition?.longitude = coordinate.longitude
    }
  }

  private func updateAzimuth(_ azimuth: Double) {
    if lastKnownPosition == nil {
      partialPosition.azimuth = azimuth
      lastKnownPosition = partialPosition.attemptPositionCreation()
    } else {
      lastKnownPosition?.azimuth = azimuth
    }
  }

  private func updateAltitude(_ altitude: Double) {
    if lastKnownPosition == nil {
      partialPosition.altitude = altitude
      lastKnownPosition = partialPosition.attemptPositionCreation()
    } else {
      lastKnownPosition?.altitude = altitude
    }
  }
}

// Each data point comes in from a separate manager, so this holds each value until all have been recorded.
private struct PartialPosition {
  var coordinate: CLLocationCoordinate2D?
  var altitude: Double?
  var azimuth: Double?

  func attemptPositionCreation() -> DevicePosition? {
    guard let coordinate = coordinate,
          let altitude = altitude,
          let azimuth = azimuth
    else { return nil }

    return DevicePosition(latitude: coordinate.latitude, longitude: coordinate.longitude, altitude: altitude, azimuth: azimuth)
  }
}
