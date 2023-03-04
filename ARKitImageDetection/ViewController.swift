/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR experience
        resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

        session.pause()
	}

    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true

    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
	func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }

        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
	}

    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {

            let imagePlaneNode = SCNNode()
            imagePlaneNode.eulerAngles.x = -.pi / 2

            // Background

            let backgroundPlane = SCNPlane(
                width: referenceImage.physicalSize.width,
                height: referenceImage.physicalSize.height
            )

            let backgroundMaterial = SCNMaterial()
            backgroundMaterial.lightingModel = .constant
            backgroundMaterial.diffuse.contents = UIImage(named: "background")
            backgroundPlane.firstMaterial = backgroundMaterial

            let backgroundPlaneNode = SCNNode(geometry: backgroundPlane)
            backgroundPlaneNode.position = SCNVector3(x: 0, y: 0, z: 0)

            imagePlaneNode.addChildNode(backgroundPlaneNode)

            // Fork

            let forkPlane = SCNPlane(
                width: referenceImage.physicalSize.width,
                height: referenceImage.physicalSize.height
            )

            let forkMaterial = SCNMaterial()
            forkMaterial.lightingModel = .constant
            forkMaterial.diffuse.contents = UIImage(named: "fork")
            forkPlane.firstMaterial = forkMaterial

            let forkInitialPosition = SCNVector3(x: 0, y: 0.04, z: 0.05)
            let forkFinalPosition = SCNVector3(x: 0, y: 0, z: 0.01)

            let forkNode = SCNNode(geometry: forkPlane)
            forkNode.position = forkInitialPosition

            let baseUnit = 0.25

            forkNode.runAction(
                .repeatForever(.sequence([
                    .move(to: forkFinalPosition, duration: baseUnit),
                    .wait(duration: 4.0 * baseUnit),
                    .move(to: forkInitialPosition, duration: baseUnit)
                ]))
            )

            imagePlaneNode.addChildNode(forkNode)

            // Electricity

            for i in 1...4 {

                let nodePlane = SCNPlane(
                    width: referenceImage.physicalSize.width,
                    height: referenceImage.physicalSize.height
                )

                let nodeMaterial = SCNMaterial()
                nodeMaterial.lightingModel = .constant
                nodeMaterial.diffuse.contents = UIImage(named: "s\(i)")
                nodePlane.firstMaterial = nodeMaterial

                let initialPosition = SCNVector3(x: 0, y: 0, z: 0.01)
                let finalPosition = SCNVector3(x: 0, y: 0, z: 0.05)

                let node = SCNNode(geometry: nodePlane)
                node.position = initialPosition
                node.opacity = 0

                node.runAction(
                    .group([
                        .repeatForever(
                            .sequence([
                                .wait(duration: baseUnit),
                                .fadeOpacity(to: 1, duration: baseUnit),
                                .wait(duration: 3.0 * baseUnit),
                                .fadeOpacity(to: 0, duration: baseUnit),
                            ])
                        ),
                        .sequence([
                            .wait(duration: baseUnit, withRange: baseUnit),
                            .repeatForever(
                                .sequence([
                                    .move(to: finalPosition, duration: baseUnit),
                                    .move(to: initialPosition, duration: baseUnit)
                                ])
                            )
                        ])
                    ])
                )

                imagePlaneNode.addChildNode(node)

            }

            // Add the plane visualization to the scene.
            node.addChildNode(imagePlaneNode)
        }

        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
}
