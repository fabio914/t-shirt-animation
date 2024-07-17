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

                let numberOfSmoke = 3

                for smokeIndex in 0 ..< numberOfSmoke {
                    var material = SimpleMaterial()
                    material.color = .init(tint: .white.withAlphaComponent(0.999), texture: .init(textureResource))

                    let width = Float(0.55 * referenceImage.physicalSize.width)
                    let depth = Float(0.55 * referenceImage.physicalSize.height)

                    let smokeEntity = ModelEntity(mesh: .generatePlane(width: width, depth: depth), materials: [material])
                    smokeEntity.position = .init(
                        x: Float(0.25 * referenceImage.physicalSize.width),
                        y: Float(-0.11 * referenceImage.physicalSize.height),
                        z: 0
                    )

                    smokeEntity.components[OpacityComponent.self] = .init(opacity: 0.75)

                    parentEntity.addChild(smokeEntity)

                    // TEST ANIMATION
                    let duration = 1.0
                    let delay = (duration/Double(numberOfSmoke)) * Double(smokeIndex)

                    var transform = smokeEntity.transform
                    transform.translation = [0.05, 0.10 , -0.20]
                    let translateAnimation = FromToByAnimation(to: transform, duration: duration, bindTarget: .transform)

                    let opacityAnimation = FromToByAnimation(to: 0.0, duration: duration, bindTarget: .opacity) // <<< This is not working....

                    let animationGroup = AnimationGroup(group: [
                        opacityAnimation,
                        translateAnimation
                    ], repeatMode: .repeat, delay: delay)

                    // Generate an AnimationResource from the AnimationViewDefinition
                    let animationResource = try! AnimationResource.generate(with: animationGroup)

                    smokeEntity.playAnimation(animationResource)
                    // END TEST ANIMATION
                }

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
