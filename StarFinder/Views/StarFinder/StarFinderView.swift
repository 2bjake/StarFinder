//
//  StarFinderView.swift
//  StarFinder
//
//  Created by Jake Foster on 1/18/22.
//

import SwiftUI
import StarCoordinates

enum Target {
  case equatorial(EquatorialCoordinates)
  case tle(TwoLineElement)
}

/// View that shows the camera and directs the user toward the location specified 
struct StarFinderView: View {
  @StateObject private var viewModel = StarFinderViewModel()
  @State private var horizontalCoords: HorizontalCoordinates
  
  let timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common)
    .autoconnect()
    .map { _ in () }
  
  let target: Target
  
  init(target: Target, initialLocation: Location) {
    self.target = target
    switch target {
      case .equatorial(let coords):
        _horizontalCoords = State(initialValue: .init(coordinates: coords, location: initialLocation, date: .now))
      case .tle(let tle):
        _horizontalCoords = State(initialValue: .init(tle: tle, location: initialLocation, date: .now))
    }
  }
  
  var body: some View {
    ZStack {
      StarFinderARView(coordinates: horizontalCoords)
        .ignoresSafeArea()

      StarFinderDirectionsView(directions: viewModel.directions(to: horizontalCoords))

      VStack {
        Text("Latitude: \(displayString(for: \.location.latitude))")
          .padding()
        Text("Longitude: \(displayString(for: \.location.longitude))")
          .padding()
        Text("Altitude: \(displayString(for: \.altitude))")
          .padding()
        Text("Azimuth: \(displayString(for: \.azimuth))")
          .padding()
      }
    }
    .onAppear { viewModel.startTracking() }
    .onDisappear { viewModel.stopTracking() }
    .onReceive(timer, perform: updateCoordinates)
  }

  func updateCoordinates() {
    guard let position = viewModel.lastKnownPosition else { return }
    switch target {
      case .equatorial(let coords):
        horizontalCoords = HorizontalCoordinates(coordinates: coords, location: position.location, date: .now)
      case .tle(let tle):
        horizontalCoords = HorizontalCoordinates(tle: tle, location: position.location, date: .now)
    }
  }

  func displayString(for keyPath: KeyPath<DevicePosition, StarCoordinates.Angle>) -> String {
    guard let value = viewModel.lastKnownPosition?[keyPath: keyPath].decimalDegrees.formattedToHundredth else { return "unknown" }
    return "\(value)"
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    StarFinderView(target: .equatorial(Star.example.coordinates), initialLocation: .init(location: .init()))
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
