import Foundation
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

    if currentPosition.altitude.decimalDegrees - target.altitude.decimalDegrees > 5 {
      directions.insert(.down)
    } else if currentPosition.altitude.decimalDegrees - target.altitude.decimalDegrees < -5 {
      directions.insert(.up)
    }

    // TODO: deal with 360 = 0
    if currentPosition.azimuth.decimalDegrees - target.azimuth.decimalDegrees > 5 {
      directions.insert(.left)
    } else if currentPosition.azimuth.decimalDegrees - target.azimuth.decimalDegrees < -5 {
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
        self?.updateLocation(location)
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

  private func updateLocation(_ location: Location) {
    if lastKnownPosition == nil {
      partialPosition.location = location
      lastKnownPosition = partialPosition.attemptPositionCreation()
    } else {
      lastKnownPosition?.location = location
    }
  }

  private func updateAzimuth(_ azimuth: Angle) {
    if lastKnownPosition == nil {
      partialPosition.azimuth = azimuth
      lastKnownPosition = partialPosition.attemptPositionCreation()
    } else {
      lastKnownPosition?.azimuth = azimuth
    }
  }

  private func updateAltitude(_ altitude: Angle) {
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
  var location: Location?
  var altitude: Angle?
  var azimuth: Angle?

  func attemptPositionCreation() -> DevicePosition? {
    guard let location = location,
          let altitude = altitude,
          let azimuth = azimuth
    else { return nil }

    return DevicePosition(location: location, altitude: altitude, azimuth: azimuth)
  }
}
