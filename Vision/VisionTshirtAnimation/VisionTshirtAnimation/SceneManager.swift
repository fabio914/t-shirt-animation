import RealityKit
import ARKit

final class SceneManager: ObservableObject {

    let rootEntity: Entity
    
    var entityMap: [UUID: Entity]
    var imageAnchors: [UUID: ImageAnchor]

    let session: ARKitSession

    init() {
        self.rootEntity = Entity()
        self.entityMap = [:]
        self.imageAnchors = [:]
        self.session = ARKitSession()
    }

    func runSession() {
        let imageInfo = ImageTrackingProvider(
            referenceImages: ReferenceImage.loadReferenceImages(inGroupNamed: "AR Resources")
        )

        if ImageTrackingProvider.isSupported {
            Task {
                do {
                    try await session.run([imageInfo])
                    for await update in imageInfo.anchorUpdates {
                        await updateImage(update.anchor)
                    }
                } catch {
                    print("AR Kit error: \(error)")
                }
            }
        } else {
            print("Not supported")
        }
    }

    @MainActor
    func updateImage(_ anchor: ImageAnchor) async {
        if imageAnchors[anchor.id] == nil {
            if let textureResource = try? await TextureResource(named: "smoke.png") {

                let referenceImage = anchor.referenceImage
                let parentEntity = Entity()

                var material = UnlitMaterial()
                material.color = .init(tint: .white.withAlphaComponent(0.9999), texture: .init(textureResource))

                let width = Float(0.55 * referenceImage.physicalSize.width)
                let depth = Float(0.55 * referenceImage.physicalSize.height)

                let smokeEntity = ModelEntity(mesh: .generatePlane(width: width, depth: depth), materials: [material])
                smokeEntity.position = .init(
                    x: Float(0.25 * referenceImage.physicalSize.width),
                    y: Float(-0.11 * referenceImage.physicalSize.height),
                    z: 0
                )

                parentEntity.addChild(smokeEntity)

                entityMap[anchor.id] = parentEntity
                rootEntity.addChild(parentEntity)
                imageAnchors[anchor.id] = anchor
            } else {
                print("Failed to load image")
            }
        }

        if anchor.isTracked {
            entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
        }
    }
}
