
import SceneKit
import ARKit
import PlaygroundSupport

final class LiveViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    let updateQueue = DispatchQueue(label: "animated.t-shirt.serialSceneKitQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARImageTrackingConfiguration.isSupported else {
            fatalError("Not supported!")
        }
        
        let sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene = SCNScene()
        
        let referenceImage = #imageLiteral(resourceName: "Photo.png")
        
        guard let referenceCGImage = referenceImage.cgImage else {
            fatalError("Missing image!")
        }
    
        let arReferenceImage = ARReferenceImage(
            referenceCGImage, 
            orientation: .up, 
            physicalWidth: 0.10
        )
        
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 1
        configuration.trackingImages = [arReferenceImage]
        
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {

            let imagePlaneNode = SCNNode()
            imagePlaneNode.eulerAngles.x = -.pi / 2

            // Smoke

            let initialSmokeOpacity = 0.9

            let smokePlane = SCNPlane(
                width: 0.55 * referenceImage.physicalSize.width,
                height: 0.55 * referenceImage.physicalSize.height
            )

            let smokeMaterial = SCNMaterial()
            smokeMaterial.lightingModel = .constant
            smokeMaterial.diffuse.contents = #imageLiteral(resourceName: "Photo 1.png")
            smokePlane.firstMaterial = smokeMaterial

            // Actions

            let smokeInitialPosition = SCNVector3(
                x: Float(CGFloat(0.25) * referenceImage.physicalSize.width),
                y: Float(CGFloat(-0.11) * referenceImage.physicalSize.height),
                z: 0
            )

            let fadeInAction = SCNAction.fadeOpacity(to: initialSmokeOpacity, duration: 0.25)

            let leftAction = SCNAction.group([
                .fadeOpacity(by: -0.10, duration: 0.25),
                .moveBy(
                    x: CGFloat(-0.20) * referenceImage.physicalSize.width,
                    y: CGFloat(0.40) * referenceImage.physicalSize.height,
                    z: 0.01,
                    duration: 0.25
                ),
                .scale(by: 1.25, duration: 0.25),
                .rotateBy(x: 0, y: 0, z: .pi/10.0, duration: 0.25)
            ])

            let rightAction = SCNAction.group([
                .fadeOpacity(by: -0.10, duration: 0.25),
                .moveBy(
                    x: CGFloat(0.20) * referenceImage.physicalSize.width,
                    y: CGFloat(0.40) * referenceImage.physicalSize.height,
                    z: 0.01,
                    duration: 0.25
                ),
                .scale(by: 1.25, duration: 0.25),
                .rotateBy(x: 0, y: 0, z: .pi/10.0, duration: 0.25)
            ])

            let leftFadeOutAction = SCNAction.group([
                .fadeOpacity(to: 0, duration: 0.25),
                .moveBy(
                    x: CGFloat(-0.20) * referenceImage.physicalSize.width,
                    y: CGFloat(0.40) * referenceImage.physicalSize.height,
                    z: 0.01,
                    duration: 0.25
                ),
                .scale(by: 1.25, duration: 0.25),
                .rotateBy(x: 0, y: 0, z: .pi/10.0, duration: 0.25)
            ])

            let resetAction = SCNAction.group([
                .move(to: smokeInitialPosition, duration: 0),
                .scale(to: 1, duration: 0),
                .rotateTo(x: 0, y: 0, z: 0, duration: 0),
                .fadeOpacity(to: 0, duration: 0)
            ])

            let repeatingSequence = SCNAction.repeatForever(
                .sequence([
                    fadeInAction,
                    rightAction,
                    leftAction,
                    rightAction,
                    leftAction,
                    rightAction,
                    leftFadeOutAction,
                    resetAction
                ])
            )

            // Additional smoke

            for i in 0 ..< 7 {
                let moreSmokePlaneNode = SCNNode(geometry: smokePlane)
                moreSmokePlaneNode.position = smokeInitialPosition
                moreSmokePlaneNode.opacity = 0

                moreSmokePlaneNode.runAction(.sequence([
                    .wait(duration: 0.25 * Double(i)),
                    repeatingSequence
                ]))

                imagePlaneNode.addChildNode(moreSmokePlaneNode)
            }
            
            node.addChildNode(imagePlaneNode)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {}
    func sessionWasInterrupted(_ session: ARSession) {}
    func sessionInterruptionEnded(_ session: ARSession) {}
}

PlaygroundPage.current.wantsFullScreenLiveView =  true
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveViewController()

