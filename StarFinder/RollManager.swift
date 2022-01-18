//
//  RollManager.swift
//  StarFinder
//
//  Created by Jake Foster on 1/18/22.
//

import CoreMotion

class RollManager {
  private let manager = CMMotionManager()
  var onRollChange: ((Double) -> Void)?

  func start() {
    guard manager.isDeviceMotionAvailable && !manager.isDeviceMotionActive else { return }
    manager.startDeviceMotionUpdates(to: .init(), withHandler: handler)
  }

  private func handler(motion: CMDeviceMotion?, error: Error?) {
    guard error == nil, let motion = motion else { return }
    onRollChange?(motion.attitude.roll)
  }

  func stop() {
    guard manager.isDeviceMotionAvailable && manager.isDeviceMotionActive else { return }
    manager.stopDeviceMotionUpdates()
  }
}

extension RollManager {
  static var stream: AsyncStream<Double> {
    AsyncStream { continuation in
      let manager = RollManager()
      manager.onRollChange = { continuation.yield($0) }
      continuation.onTermination = { @Sendable _ in manager.stop() }
      manager.start()
    }
  }
}
