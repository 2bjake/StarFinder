import StarCoordinates
import Foundation

@MainActor
class StarDetailViewModel: ObservableObject {

  @Published private(set) var lastKnownLocation: Location?
  private var locationTask: Task<Void, Never>?

  func startTracking() {
    guard locationTask == nil else { return }
    locationTask = Task { [weak self] in
      let locationManager = LocationManager()
      for await location in locationManager.makeStream() {
        self?.lastKnownLocation = location
      }
    }
  }

  func stopTracking() {
    locationTask?.cancel()
    locationTask = nil
  }

  deinit {
    locationTask?.cancel()
  }
}
