import CoreLocation

class MagneticHeadingManager: NSObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private var isRunning = false
  private var onHeadingChange: ((Double) -> Void)?

  override init() {
    super.init()
    manager.delegate = self
  }

  private func start() {
    guard !isRunning else { return }
    isRunning = true
    manager.requestWhenInUseAuthorization()
    manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    manager.headingOrientation = .landscapeLeft
    manager.startUpdatingHeading()
  }

  private func stop() {
    guard isRunning else { return }
    isRunning = false
    manager.stopUpdatingHeading()
  }

  func makeStream() -> AsyncStream<Double> {
    guard !isRunning else { fatalError("Attempted to start stream when it's already running.") }

    return AsyncStream { continuation in
      onHeadingChange = { continuation.yield($0) }
      continuation.onTermination = { @Sendable _ in self.stop() }
      start()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    onHeadingChange?(newHeading.trueHeading)
  }
}
