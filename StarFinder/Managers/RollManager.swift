//
//  RollManager.swift
//  StarFinder
//
//  Created by Jake Foster on 1/18/22.
//

import CoreMotion

class RollManager {
  private let manager = CMMotionManager()
  private var onRollChange: ((Double) -> Void)?

  private func start() {
    guard manager.isDeviceMotionAvailable && !manager.isDeviceMotionActive else { return }
    manager.startDeviceMotionUpdates(to: .init(), withHandler: handler)
  }

  private func handler(motion: CMDeviceMotion?, error: Error?) {
    guard error == nil, let motion = motion else { return }
    onRollChange?(motion.attitude.roll)
  }

  private func stop() {
    guard manager.isDeviceMotionAvailable && manager.isDeviceMotionActive else { return }
    manager.stopDeviceMotionUpdates()
  }

  var stream: AsyncStream<Double> {
    AsyncStream { continuation in
      onRollChange = { continuation.yield($0) }
      continuation.onTermination = { @Sendable _ in self.stop() }
      start()
    }
  }
}
