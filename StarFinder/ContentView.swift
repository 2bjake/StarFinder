//
//  ContentView.swift
//  StarFinder
//
//  Created by Jake Foster on 1/18/22.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = StarFinderViewModel()

  func displayString(for keyPath: KeyPath<DevicePosition, Double>) -> String {
    guard let value = viewModel.lastKnownPosition?[keyPath: keyPath] else { return "unknown" }
    return "\(value)"
  }

  // TODO: don't hardcode this 🙃
  var target: DevicePosition {
    .init(latitude: 0, longitude: 0, altitude: 30, azimuth: 0)
  }

  var body: some View {
    ZStack {
      WayfinderView(directions: viewModel.directions(to: target))

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
    ContentView()
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
