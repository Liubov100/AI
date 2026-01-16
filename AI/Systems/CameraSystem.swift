//
//  CameraSystem.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI
import SceneKit
import Combine

// MARK: - Camera Controller
class CameraController: ObservableObject {
    @Published var position = SCNVector3(x: 0, y: 5, z: 10)
    @Published var lookAt = SCNVector3(x: 0, y: 0, z: 0)
    @Published var fov: CGFloat = 60
    @Published var cameraMode: CameraMode = .followBehind

    private var targetPosition = SCNVector3Zero
    private let smoothSpeed: Float = 0.1
    private let cameraDistance: Float = 8.0
    private let cameraHeight: Float = 5.0

    enum CameraMode {
        case followBehind  // Third-person behind cat
        case followAbove   // Top-down view
        case cinematic     // Smooth cinematic camera
        case free          // Manual control
    }

    // MARK: - Camera Updates
    func update(targetPosition: CGPoint, facingDirection: CatController.Direction) {
        let target3D = SCNVector3(
            x: Float(targetPosition.x),
            y: 0,
            z: Float(targetPosition.y)
        )

        self.targetPosition = target3D

        switch cameraMode {
        case .followBehind:
            updateFollowBehindCamera(target: target3D, direction: facingDirection)
        case .followAbove:
            updateFollowAboveCamera(target: target3D)
        case .cinematic:
            updateCinematicCamera(target: target3D)
        case .free:
            break // User controlled
        }
    }

    private func updateFollowBehindCamera(target: SCNVector3, direction: CatController.Direction) {
        // Calculate camera offset based on facing direction
        var offset = SCNVector3Zero

        switch direction {
        case .right:
            offset = SCNVector3(x: -cameraDistance, y: cameraHeight, z: 0)
        case .left:
            offset = SCNVector3(x: cameraDistance, y: cameraHeight, z: 0)
        case .up:
            offset = SCNVector3(x: 0, y: cameraHeight, z: cameraDistance)
        case .down:
            offset = SCNVector3(x: 0, y: cameraHeight, z: -cameraDistance)
        }

        let desiredPosition = SCNVector3(
            x: target.x + offset.x,
            y: target.y + offset.y,
            z: target.z + offset.z
        )

        // Smooth camera movement
        position = lerpVector(from: position, to: desiredPosition, t: smoothSpeed)
        lookAt = lerpVector(from: lookAt, to: target, t: smoothSpeed * 1.5)
    }

    private func updateFollowAboveCamera(target: SCNVector3) {
        let desiredPosition = SCNVector3(
            x: target.x,
            y: target.y + 15,
            z: target.z + 5
        )

        position = lerpVector(from: position, to: desiredPosition, t: smoothSpeed)
        lookAt = lerpVector(from: lookAt, to: target, t: smoothSpeed * 1.5)
    }

    private func updateCinematicCamera(target: SCNVector3) {
        // Circular motion around target
        let time = Date().timeIntervalSince1970
        let angle = Float(time * 0.5)

        let desiredPosition = SCNVector3(
            x: target.x + cos(angle) * cameraDistance,
            y: target.y + cameraHeight,
            z: target.z + sin(angle) * cameraDistance
        )

        position = lerpVector(from: position, to: desiredPosition, t: smoothSpeed * 0.5)
        lookAt = target
    }

    // MARK: - Camera Controls
    func zoom(delta: CGFloat) {
        fov = max(30, min(120, fov + delta))
    }

    func setCameraMode(_ mode: CameraMode) {
        cameraMode = mode
    }

    func panCamera(delta: CGPoint) {
        guard cameraMode == .free else { return }

        position.x += Float(delta.x) * 0.1
        position.z += Float(delta.y) * 0.1
    }

    // MARK: - Helper Functions
    private func lerpVector(from: SCNVector3, to: SCNVector3, t: Float) -> SCNVector3 {
        return SCNVector3(
            x: from.x + (to.x - from.x) * t,
            y: from.y + (to.y - from.y) * t,
            z: from.z + (to.z - from.z) * t
        )
    }
}

// MARK: - Scene3D View
struct Scene3DView: View {
    @ObservedObject var cameraController: CameraController
    @ObservedObject var catController: CatController
    @Binding var collectables: [Collectable]
    @Binding var interactiveObjects: [InteractiveObject]

    var body: some View {
        SceneView(
            scene: createScene(),
            pointOfView: createCamera(),
            options: [.allowsCameraControl, .autoenablesDefaultLighting, .temporalAntialiasingEnabled]
        )
        .onAppear {
            // Initialize camera position
            cameraController.update(targetPosition: catController.position, facingDirection: catController.facingDirection)
        }
    }

    private func createScene() -> SCNScene {
        let scene = SCNScene()

        // Ground plane
        let ground = SCNNode()
        let groundGeometry = SCNPlane(width: 100, height: 100)
        groundGeometry.firstMaterial?.diffuse.contents = NSColor(red: 0.5, green: 0.7, blue: 0.4, alpha: 1.0)
        ground.geometry = groundGeometry
        ground.eulerAngles = SCNVector3(x: -.pi / 2, y: 0, z: 0)
        scene.rootNode.addChildNode(ground)

        // Add cat
        let catNode = createCatNode()
        catNode.position = SCNVector3(
            x: Float(catController.position.x),
            y: 0.5,
            z: Float(catController.position.y)
        )
        scene.rootNode.addChildNode(catNode)

        // Add collectables as 3D objects
        for collectable in collectables.filter({ !$0.isCollected }) {
            let collectableNode = createCollectableNode(type: collectable.type)
            collectableNode.position = SCNVector3(
                x: Float(collectable.position.x),
                y: 0.5,
                z: Float(collectable.position.y)
            )
            scene.rootNode.addChildNode(collectableNode)
        }

        // Add interactive objects
        for object in interactiveObjects {
            let objectNode = createInteractiveObjectNode(type: object.type)
            objectNode.position = SCNVector3(
                x: Float(object.position.x),
                y: 1,
                z: Float(object.position.y)
            )
            scene.rootNode.addChildNode(objectNode)
        }

        return scene
    }

    private func createCamera() -> SCNNode {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = cameraController.fov
        camera.zNear = 0.1
        camera.zFar = 1000
        cameraNode.camera = camera

        cameraNode.position = cameraController.position
        cameraNode.look(at: cameraController.lookAt)

        return cameraNode
    }

    private func createCatNode() -> SCNNode {
        let node = SCNNode()

        // Body
        let body = SCNBox(width: 0.6, height: 0.4, length: 0.8, chamferRadius: 0.1)
        body.firstMaterial?.diffuse.contents = NSColor.black
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(x: 0, y: 0.2, z: 0)
        node.addChildNode(bodyNode)

        // Head
        let head = SCNSphere(radius: 0.25)
        head.firstMaterial?.diffuse.contents = NSColor.black
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(x: 0, y: 0.5, z: 0.4)
        node.addChildNode(headNode)

        // Ears
        let ear = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
        ear.firstMaterial?.diffuse.contents = NSColor.black

        let leftEar = SCNNode(geometry: ear)
        leftEar.position = SCNVector3(x: -0.15, y: 0.65, z: 0.4)
        node.addChildNode(leftEar)

        let rightEar = SCNNode(geometry: ear)
        rightEar.position = SCNVector3(x: 0.15, y: 0.65, z: 0.4)
        node.addChildNode(rightEar)

        // Eyes
        let eye = SCNSphere(radius: 0.06)
        eye.firstMaterial?.diffuse.contents = NSColor.green
        eye.firstMaterial?.emission.contents = NSColor.green.withAlphaComponent(0.5)

        let leftEye = SCNNode(geometry: eye)
        leftEye.position = SCNVector3(x: -0.1, y: 0.55, z: 0.6)
        node.addChildNode(leftEye)

        let rightEye = SCNNode(geometry: eye)
        rightEye.position = SCNVector3(x: 0.1, y: 0.55, z: 0.6)
        node.addChildNode(rightEye)

        // Tail
        let tail = SCNCylinder(radius: 0.05, height: 0.6)
        tail.firstMaterial?.diffuse.contents = NSColor.black
        let tailNode = SCNNode(geometry: tail)
        tailNode.position = SCNVector3(x: 0, y: 0.3, z: -0.5)
        tailNode.eulerAngles = SCNVector3(x: 0.5, y: 0, z: 0)
        node.addChildNode(tailNode)

        return node
    }

    private func createCollectableNode(type: CollectableType) -> SCNNode {
        let node = SCNNode()

        switch type {
        case .shiny:
            let star = SCNPyramid(width: 0.3, height: 0.3, length: 0.3)
            star.firstMaterial?.diffuse.contents = NSColor.yellow
            star.firstMaterial?.emission.contents = NSColor.yellow.withAlphaComponent(0.5)
            node.geometry = star

        case .fish:
            let fish = SCNBox(width: 0.3, height: 0.1, length: 0.5, chamferRadius: 0.05)
            fish.firstMaterial?.diffuse.contents = NSColor.cyan
            node.geometry = fish

        case .feather:
            let feather = SCNCylinder(radius: 0.05, height: 0.4)
            feather.firstMaterial?.diffuse.contents = NSColor.green
            node.geometry = feather

        case .hat:
            let hat = SCNCone(topRadius: 0.1, bottomRadius: 0.3, height: 0.4)
            hat.firstMaterial?.diffuse.contents = NSColor.purple
            node.geometry = hat
        }

        // Floating animation
        let animation = SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 1.0),
            SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 1.0)
        ])
        node.runAction(SCNAction.repeatForever(animation))

        return node
    }

    private func createInteractiveObjectNode(type: ObjectType) -> SCNNode {
        let node = SCNNode()

        switch type {
        case .box:
            let box = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0.05)
            box.firstMaterial?.diffuse.contents = NSColor.brown
            node.geometry = box

        case .trashCan:
            let can = SCNCylinder(radius: 0.4, height: 1.0)
            can.firstMaterial?.diffuse.contents = NSColor.gray
            node.geometry = can

        case .vase:
            let vase = SCNCylinder(radius: 0.3, height: 0.8)
            vase.firstMaterial?.diffuse.contents = NSColor.red
            node.geometry = vase

        case .bird:
            let bird = SCNSphere(radius: 0.2)
            bird.firstMaterial?.diffuse.contents = NSColor.gray
            node.geometry = bird

        default:
            let placeholder = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.1)
            placeholder.firstMaterial?.diffuse.contents = NSColor.lightGray
            node.geometry = placeholder
        }

        return node
    }
}

// MARK: - Camera Mode Picker
struct CameraModePickerView: View {
    @ObservedObject var cameraController: CameraController

    var body: some View {
        HStack(spacing: 10) {
            Text("Camera:")
                .font(.caption)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2)

            ForEach([CameraController.CameraMode.followBehind, .followAbove, .cinematic, .free], id: \.self) { mode in
                Button(action: {
                    cameraController.setCameraMode(mode)
                }) {
                    Text(modeName(mode))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(cameraController.cameraMode == mode ? Color.blue : Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.6))
        )
    }

    private func modeName(_ mode: CameraController.CameraMode) -> String {
        switch mode {
        case .followBehind: return "Follow"
        case .followAbove: return "Top"
        case .cinematic: return "Cinematic"
        case .free: return "Free"
        }
    }
}

#Preview {
    Scene3DView(
        cameraController: CameraController(),
        catController: CatController(),
        collectables: .constant([]),
        interactiveObjects: .constant([])
    )
}
