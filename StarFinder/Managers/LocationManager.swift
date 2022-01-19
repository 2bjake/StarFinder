import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
  private let manager = CLLocationManager()
  private(set) var isRunning = false
  private var onLocationChange: ((CLLocationCoordinate2D) -> Void)?

  override init() {
    super.init()
    manager.delegate = self
  }

  private func start() {
    guard !isRunning else { return }
    manager.requestWhenInUseAuthorization()
    manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    manager.startUpdatingLocation()
    isRunning = true
  }

  private func stop() {
    manager.stopUpdatingLocation()
    isRunning = false
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // !-safe, from docs: This array always contains at least one object
    onLocationChange?(locations.last!.coordinate)
  }

  var stream: AsyncStream<CLLocationCoordinate2D> {
    guard !isRunning else { fatalError("Attempted to start stream when it is already running.") }

    return AsyncStream { continuation in
      onLocationChange = { continuation.yield($0) }
      continuation.onTermination = { @Sendable _ in self.stop() }
      start()
    }
  }
}
