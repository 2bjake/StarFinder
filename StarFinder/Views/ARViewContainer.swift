import SwiftUI
import RealityKit

// TODO: handle camera permission not granted
struct ARViewContainer: UIViewRepresentable {
  func makeUIView(context: Context) -> ARView { .init(frame: .zero) }

  func updateUIView(_ uiView: ARView, context: Context) { }
}
