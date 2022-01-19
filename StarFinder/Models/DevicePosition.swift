// All values are in degrees
struct DevicePosition {
  var latitude: Double
  var longitude: Double
  var altitude: Double
  var azimuth: Double
}

extension DevicePosition {
  static var example: DevicePosition { .init(latitude: 0, longitude: 0, altitude: 30, azimuth: 0) }
}
