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

  var body: some View {
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
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
