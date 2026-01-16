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
@MainActor
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
            x: CGFloat(targetPosition.x),
            y: 0,
            z: CGFloat(targetPosition.y)
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
            offset = SCNVector3(x: CGFloat(-cameraDistance), y: CGFloat(cameraHeight), z: 0)
        case .left:
            offset = SCNVector3(x: CGFloat(cameraDistance), y: CGFloat(cameraHeight), z: 0)
        case .up:
            offset = SCNVector3(x: 0, y: CGFloat(cameraHeight), z: CGFloat(cameraDistance))
        case .down:
            offset = SCNVector3(x: 0, y: CGFloat(cameraHeight), z: CGFloat(-cameraDistance))
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
        let angle = CGFloat(time * 0.5)

        let desiredPosition = SCNVector3(
            x: target.x + cos(angle) * CGFloat(cameraDistance),
            y: target.y + CGFloat(cameraHeight),
            z: target.z + sin(angle) * CGFloat(cameraDistance)
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

        position.x += delta.x * 0.1
        position.z += delta.y * 0.1
    }

    // MARK: - Helper Functions
    private func lerpVector(from: SCNVector3, to: SCNVector3, t: Float) -> SCNVector3 {
        let tCG = CGFloat(t)
        return SCNVector3(
            x: from.x + (to.x - from.x) * tCG,
            y: from.y + (to.y - from.y) * tCG,
            z: from.z + (to.z - from.z) * tCG
        )
    }
}

// MARK: - Scene Manager
@MainActor
class SceneManager: ObservableObject {
    let scene = SCNScene()
    let cameraNode = SCNNode()
    private var catNode: SCNNode?
    private var playerNodes: [String: SCNNode] = [:]
    private var updateTimer: Timer?

    func setupScene() {
        // Ground plane
        let ground = SCNNode()
        let groundGeometry = SCNPlane(width: 100, height: 100)
        groundGeometry.firstMaterial?.diffuse.contents = NSColor(red: 0.5, green: 0.7, blue: 0.4, alpha: 1.0)
        ground.geometry = groundGeometry
        ground.eulerAngles = SCNVector3(x: -.pi / 2, y: 0, z: 0)
        scene.rootNode.addChildNode(ground)

        // Setup camera
        let camera = SCNCamera()
        camera.fieldOfView = 60
        camera.zNear = 0.1
        camera.zFar = 1000
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        scene.rootNode.addChildNode(cameraNode)

        // Create cat node
        catNode = createCatNode()
        catNode?.position = SCNVector3(x: 0, y: 0.5, z: 0)
        scene.rootNode.addChildNode(catNode!)

        // Add ambient light to reduce flashing
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = NSColor(white: 0.6, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)

        // Add directional light (sun)
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light!.type = .directional
        sunLight.light!.color = NSColor(white: 0.8, alpha: 1.0)
        sunLight.light!.castsShadow = true
        sunLight.position = SCNVector3(x: 10, y: 20, z: 10)
        sunLight.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(sunLight)
    }

    func updateCatPosition(_ position: CGPoint) {
        catNode?.position = SCNVector3(
            x: CGFloat(position.x),
            y: 0.5,
            z: CGFloat(position.y)
        )
    }

    func updateCamera(_ position: SCNVector3, lookAt: SCNVector3) {
        cameraNode.position = position
        cameraNode.look(at: lookAt)
    }

    func updateNetworkPlayers(_ players: [NetworkPlayer]) {
        // Remove old player nodes that are no longer connected
        let playerIds = Set(players.map { $0.id })
        for (id, node) in playerNodes where !playerIds.contains(id) {
            node.removeFromParentNode()
            playerNodes.removeValue(forKey: id)
        }

        // Update or create player nodes
        for player in players {
            if let existingNode = playerNodes[player.id] {
                // Update position
                existingNode.position = SCNVector3(
                    x: CGFloat(player.position.x),
                    y: 0.5,
                    z: CGFloat(player.position.y)
                )
            } else {
                // Create new player node
                let playerNode = createNetworkPlayerNode(player: player)
                playerNode.position = SCNVector3(
                    x: CGFloat(player.position.x),
                    y: 0.5,
                    z: CGFloat(player.position.y)
                )
                scene.rootNode.addChildNode(playerNode)
                playerNodes[player.id] = playerNode
            }
        }
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

    private func createNetworkPlayerNode(player: NetworkPlayer) -> SCNNode {
        let node = SCNNode()
        node.name = player.id

        // Body (smaller than local player)
        let body = SCNBox(width: 0.5, height: 0.35, length: 0.7, chamferRadius: 0.08)
        body.firstMaterial?.diffuse.contents = NSColor.gray
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(x: 0, y: 0.175, z: 0)
        node.addChildNode(bodyNode)

        // Head
        let head = SCNSphere(radius: 0.2)
        head.firstMaterial?.diffuse.contents = NSColor.darkGray
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(x: 0, y: 0.4, z: 0.3)
        node.addChildNode(headNode)

        // Name tag
        let text = SCNText(string: player.name, extrusionDepth: 0.02)
        text.font = NSFont.systemFont(ofSize: 0.15)
        text.firstMaterial?.diffuse.contents = NSColor.white
        text.firstMaterial?.emission.contents = NSColor.white
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(x: -0.2, y: 0.8, z: 0)
        textNode.scale = SCNVector3(0.5, 0.5, 0.5)
        node.addChildNode(textNode)

        // Level badge
        let levelText = SCNText(string: "Lv.\(player.level)", extrusionDepth: 0.01)
        levelText.font = NSFont.boldSystemFont(ofSize: 0.12)
        levelText.firstMaterial?.diffuse.contents = NSColor.yellow
        let levelNode = SCNNode(geometry: levelText)
        levelNode.position = SCNVector3(x: -0.15, y: 0.95, z: 0)
        levelNode.scale = SCNVector3(0.4, 0.4, 0.4)
        node.addChildNode(levelNode)

        return node
    }
}

// MARK: - Scene3D View
struct Scene3DView: View {
    @ObservedObject var cameraController: CameraController
    @ObservedObject var catController: CatController
    @ObservedObject var networkManager: NetworkManager
    @Binding var collectables: [Collectable]
    @Binding var interactiveObjects: [InteractiveObject]

    @StateObject private var sceneManager = SceneManager()

    var body: some View {
        SceneView(
            scene: sceneManager.scene,
            pointOfView: sceneManager.cameraNode,
            options: [.autoenablesDefaultLighting, .temporalAntialiasingEnabled]
        )
        .onAppear {
            sceneManager.setupScene()
            sceneManager.startUpdateLoop(
                catController: catController,
                cameraController: cameraController,
                networkManager: networkManager
            )
        }
        .onDisappear {
            sceneManager.stopUpdateLoop()
        }
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
        networkManager: NetworkManager.shared,
        collectables: .constant([]),
        interactiveObjects: .constant([])
    )
}
