//
//  StarFinderView.swift
//  StarFinder
//
//  Created by Jake Foster on 1/18/22.
//

import SwiftUI
import StarCoordinates

extension HorizontalCoordinates {
  static var example: Self { HorizontalCoordinates(altitudeDeg: 30, azimuthDeg: 0) }
}

struct StarFinderView: View {
  @StateObject private var viewModel = StarFinderViewModel()

  func displayString(for keyPath: KeyPath<DevicePosition, Double>) -> String {
    guard let value = viewModel.lastKnownPosition?[keyPath: keyPath] else { return "unknown" }
    return "\(value)"
  }

  let target: HorizontalCoordinates

  var body: some View {
    ZStack {
      ViewfinderDirectionsView(directions: viewModel.directions(to: target))

      VStack {
        Text("Latitude: \(displayString(for: \.latitude))")
          .padding()
        Text("Longitude: \(displayString(for: \.longitude))")
          .padding()
        Text("Altitude: \(displayString(for: \.altitude))")
          .padding()
        Text("Azimuth: \(displayString(for: \.azimuth))")
          .padding()

        //Button("Start") { viewModel.startTracking() }
        //Button("Stop") { viewModel.stopTracking() }
      }
    }
    .onAppear { viewModel.startTracking() }
    .onDisappear { viewModel.stopTracking() }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    StarFinderView(target: .example)
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
