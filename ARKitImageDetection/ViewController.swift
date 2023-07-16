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

            // UFO

            let ufoPlane = SCNPlane(
                width: 0.55 * referenceImage.physicalSize.width,
                height: 0.55 * referenceImage.physicalSize.height
            )

            let ufoMaterial = SCNMaterial()
            ufoMaterial.lightingModel = .constant
            ufoMaterial.diffuse.contents = UIImage(named: "ufo")
            ufoPlane.firstMaterial = ufoMaterial

            let initialPositions: [SCNVector3] = [
                .init(
                    0.4 * referenceImage.physicalSize.width,
                    -1.0 * referenceImage.physicalSize.height,
                    0.01
                ),
                .init(
                    -0.4 * referenceImage.physicalSize.width,
                    -1.0 * referenceImage.physicalSize.height,
                    0.01
                ),
                .init(
                    0.3 * referenceImage.physicalSize.width,
                    -0.5 * referenceImage.physicalSize.height,
                    0.01
                ),
                .init(
                    -0.3 * referenceImage.physicalSize.width,
                     -0.5 * referenceImage.physicalSize.height,
                    0.01
                ),
                .init(
                    0.5 * referenceImage.physicalSize.width,
                    -0.25 * referenceImage.physicalSize.height,
                    0.01
                ),
                .init(
                    -0.5 * referenceImage.physicalSize.width,
                     -0.25 * referenceImage.physicalSize.height,
                    0.01
                )
            ]


            for initialPosition in initialPositions {
                let ufoNode = SCNNode(geometry: ufoPlane)
                ufoNode.position = .init(0, 0, 0.05)
                ufoNode.opacity = 1

                ufoNode.runAction(
                    .repeatForever(
                        .sequence([
                            .group([
                                .move(to: initialPosition, duration: 0),
                                .scale(to: 0, duration: 0),
                                .fadeOpacity(to: 0, duration: 0)
                            ]),
                            .wait(duration: 0.25, withRange: 1.0),
                            .group([
                                .moveBy(x: 0, y: 0, z: 0.05, duration: 0.25),
                                .fadeOpacity(to: 1.0, duration: 0.25),
                                .scale(to: 1.0, duration: 0.25)
                            ]),
                            .moveBy(x: -0.1 * referenceImage.physicalSize.width, y: 0, z: 0.125, duration: 0.125),
                            .moveBy(x: 0.2 * referenceImage.physicalSize.width, y: 0, z: 0.125, duration: 0.125),
                            .moveBy(x: -0.2 * referenceImage.physicalSize.width, y: 0, z: 0.125, duration: 0.125),
                            .moveBy(x: 0.2 * referenceImage.physicalSize.width, y: 0, z: 0.125, duration: 0.125),
                            .moveBy(x: -0.2 * referenceImage.physicalSize.width, y: 0, z: 0.125, duration: 0.125),
                            .moveBy(x: 0.1 * referenceImage.physicalSize.width, y: 0, z: 0.125, duration: 0.125),
                            .fadeOpacity(to: 0, duration: 0.125)
                        ])
                    )
                )

                imagePlaneNode.addChildNode(ufoNode)
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
