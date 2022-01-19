//
//  AltitudeManager.swift
//  StarFinder
//
//  Created by Jake Foster on 1/18/22.
//

import CoreMotion

class AltitudeManager {
  private let manager = CMMotionManager()
  private var onAltitudeChange: ((Double) -> Void)?

  private var isRunning: Bool { manager.isDeviceMotionActive }

  private func start() {
    guard manager.isDeviceMotionAvailable && !manager.isDeviceMotionActive else { return }
    manager.startDeviceMotionUpdates(to: .init()) { [weak self] in self?.handler(motion: $0, error: $1) }
  }

  private func handler(motion: CMDeviceMotion?, error: Error?) {
    guard error == nil, let motion = motion else { return }
    let rollRadians = motion.attitude.roll
    let altitudeDegrees = -rollRadians * 180 / .pi - 90 // TODO: what to do for >90?
    onAltitudeChange?(altitudeDegrees)
  }

  private func stop() {
    guard isRunning else { return }
    manager.stopDeviceMotionUpdates()
  }

  func makeStream() -> AsyncStream<Double> {
    guard !isRunning else { fatalError("Attempted to start stream when it's already running.") }

    return AsyncStream { continuation in
      onAltitudeChange = { continuation.yield($0) }
      continuation.onTermination = { @Sendable [weak self] _ in self?.stop() }
      start()
    }
  }
}
