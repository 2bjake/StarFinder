//
//  StarFinderView.swift
//  StarFinder
//
//  Created by Jake Foster on 1/18/22.
//

import SwiftUI
import StarCoordinates
import CoreLocation

/// View that shows the camera and directs the user toward the location specified 
struct StarFinderView: View {
  @StateObject private var viewModel = StarFinderViewModel()
  @State private var horizontalCoords: HorizontalCoordinates

  let timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common)
    .autoconnect()
    .map { _ in () }

  let equatorialCoords: EquatorialCoordinates

  init(equatorialCoords: EquatorialCoordinates, initialLocation: CLLocationCoordinate2D) {
    self.equatorialCoords = equatorialCoords
    _horizontalCoords = State(initialValue: .init(coordinates: equatorialCoords, location: initialLocation, date: .now))
  }

  var body: some View {
    ZStack {
      ARViewContainer()
        .ignoresSafeArea()

      ViewfinderDirectionsView(directions: viewModel.directions(to: horizontalCoords))

      VStack {
        Text("Latitude: \(displayString(for: \.latitude))")
          .padding()
        Text("Longitude: \(displayString(for: \.longitude))")
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
    horizontalCoords = HorizontalCoordinates(coordinates: equatorialCoords, location: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude), date: .now)
  }

  func displayString(for keyPath: KeyPath<DevicePosition, Double>) -> String {
    guard let value = viewModel.lastKnownPosition?[keyPath: keyPath].formattedToHundredth else { return "unknown" }
    return "\(value)"
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    StarFinderView(equatorialCoords: Star.example.coordinates, initialLocation: .init())
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
