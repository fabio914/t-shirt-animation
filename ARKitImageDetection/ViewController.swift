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

            // Smoke

            let initialSmokeOpacity = 0.9

            let smokePlane = SCNPlane(
                width: 0.55 * referenceImage.physicalSize.width,
                height: 0.55 * referenceImage.physicalSize.height
            )

            let smokeMaterial = SCNMaterial()
            smokeMaterial.lightingModel = .constant
            smokeMaterial.diffuse.contents = UIImage(named: "smoke")
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
