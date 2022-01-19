//
//  WayfinderView.swift
//  StarFinder
//
//  Created by Jake Foster on 1/19/22.
//

import SwiftUI

struct WayfinderView: View {
  

  var directions: Set<WayfinderDirection>

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Image(systemName: "chevron.compact.up")
          .font(.largeTitle)
          .padding()
          .opacity(directions.contains(.up) ? 1 : 0)
        Spacer()
      }

      Spacer()

      HStack {
        Image(systemName: "chevron.compact.left")
          .font(.largeTitle)
          .padding()
          .opacity(directions.contains(.left) ? 1 : 0)
        Spacer()
        Image(systemName: "viewfinder")
          .font(.largeTitle)
          .padding()
          .opacity(directions.contains(.center) ? 1 : 0)
        Spacer()
        Image(systemName: "chevron.compact.right")
          .font(.largeTitle)
          .padding()
          .opacity(directions.contains(.right) ? 1 : 0)
      }

      Spacer()

      HStack {
        Spacer()
        Image(systemName: "chevron.compact.down")
          .font(.largeTitle)
          .padding()
          .opacity(directions.contains(.down) ? 1 : 0)
        Spacer()
      }
    }
  }
}

struct WayfinderView_Previews: PreviewProvider {
  static var previews: some View {
    WayfinderView(directions: [])
  }
}
