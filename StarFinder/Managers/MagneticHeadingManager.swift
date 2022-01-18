import CoreLocation

class MagneticHeadingManager: NSObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private(set) var isRunning = false
  private var onHeadingChange: ((Double) -> Void)?

  override init() {
    super.init()
    manager.delegate = self
  }

  private func start() {
    guard !isRunning else { return }
    manager.requestWhenInUseAuthorization()
    manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    manager.startUpdatingHeading()
    isRunning = true
  }

  func stop() {
    guard isRunning else { return }
    manager.stopUpdatingHeading()
    isRunning = false
  }

  var stream: AsyncStream<Double> {
    AsyncStream { continuation in
      onHeadingChange = {
        continuation.yield($0)
      }
      continuation.onTermination = { @Sendable _ in self.stop() }
      start()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    onHeadingChange?(newHeading.trueHeading)
  }
}
