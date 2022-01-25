import SwiftUI
import RealityKit
import ARKit
import StarCoordinates

// TODO: handle camera permission not granted
struct StarFinderARView: UIViewRepresentable {
  class View: ARView, ARSessionDelegate { }

  let coordinates: HorizontalCoordinates

  func makeUIView(context: Context) -> View {
    let view = View(frame: .zero)
    view.session.delegate = view
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravityAndHeading // +x is east, +y is up, +z is south
    view.session.run(config)

    let originAnchor = AnchorEntity()
    originAnchor.addChild(Self.makeStar(at: coordinates))
    view.scene.addAnchor(originAnchor)
    return view
  }

  private static func makeStar(at coordinates: HorizontalCoordinates) -> Entity {
    let mesh = MeshResource.generateSphere(radius: 1)
    let material = SimpleMaterial(color: .blue, roughness: 0.8, isMetallic: false)
    let entity = ModelEntity(mesh: mesh, materials: [material]) // TODO: make this a viewfinder window

    let radius = 50.0
    let phi = coordinates.altitude.radians - .pi / 2
    let theta = coordinates.azimuth.radians

    let x = -Float(radius * sin(phi) * sin(theta))
    let y = Float(radius * cos(phi))
    let z = Float(radius * sin(phi) * cos(theta))

    entity.position = .init(x: x, y: y, z: z)
    return entity
  }

  func updateUIView(_ uiView: View, context: Context) { }
}


