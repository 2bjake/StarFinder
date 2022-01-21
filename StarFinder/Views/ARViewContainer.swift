import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
  func makeUIView(context: Context) -> ARView { .init(frame: .zero) }

  func updateUIView(_ uiView: ARView, context: Context) { }
}
