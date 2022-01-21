import Foundation
import CoreLocation
import StarCoordinates

enum WayfinderDirection { case up, down, left, right, center }

@MainActor
final class StarFinderViewModel: ObservableObject {
  private var partialPosition = PartialPosition()

  private var locationTask: Task<Void, Never>?
  private var headingTask: Task<Void, Never>?
  private var altitudeTask: Task<Void, Never>?

  private var isTracking = false

  @Published private(set) var lastKnownPosition: DevicePosition?

  func directions(to target: HorizontalCoordinates) -> Set<WayfinderDirection> {
    var directions = Set<WayfinderDirection>()
    guard let currentPosition = lastKnownPosition else { return directions }

    if currentPosition.altitude - target.altitudeDeg > 5 {
      directions.insert(.down)
    } else if currentPosition.altitude - target.altitudeDeg < -5 {
      directions.insert(.up)
    }

    // TODO: deal with 360 = 0
    if currentPosition.azimuth - target.azimuthDeg > 5 {
      directions.insert(.left)
    } else if currentPosition.azimuth - target.azimuthDeg < -5 {
      directions.insert(.right)
    }

    if directions.isEmpty {
      directions.insert(.center)
    }

    return directions
  }

  func startTracking() {
    guard !isTracking else { return }
    isTracking = true

    altitudeTask = Task { [weak self] in
      let altitudeManager = AltitudeManager()
      for await altitude in altitudeManager.makeStream() {
        self?.updateAltitude(altitude)
      }
    }

    locationTask = Task { [weak self] in
      let locationManager = LocationManager()
      for await location in locationManager.makeStream() {
        self?.updateCoordinate(location)
      }
    }

    headingTask = Task { [weak self] in
      let headingManager = MagneticHeadingManager()
      for await heading in headingManager.makeStream() {
        self?.updateAzimuth(heading)
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
