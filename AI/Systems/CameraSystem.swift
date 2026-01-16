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
class SceneManager: NSObject, ObservableObject, SCNSceneRendererDelegate {
    let scene = SCNScene()
    let cameraNode = SCNNode()
    private var catNode: SCNNode?
    private var playerNodes: [String: SCNNode] = [:]

    private weak var catController: CatController?
    private weak var cameraController: CameraController?
    private weak var networkManager: NetworkManager?

    private var collectableNodes: [String: SCNNode] = [:]
    private var interactiveObjectNodes: [String: SCNNode] = [:]

    func setupScene() {
        // Ground - City street with grid pattern
        let ground = SCNNode()
        let groundGeometry = SCNPlane(width: 100, height: 100)
        groundGeometry.firstMaterial?.diffuse.contents = NSColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
        groundGeometry.firstMaterial?.roughness.contents = NSColor(white: 0.8, alpha: 1.0)
        groundGeometry.firstMaterial?.metalness.contents = 0.1
        ground.geometry = groundGeometry
        ground.eulerAngles = SCNVector3(x: -.pi / 2, y: 0, z: 0)
        scene.rootNode.addChildNode(ground)

        // Add grid lines for street effect
        createStreetGrid()

        // Add buildings
        createBuildings()

        // Add trees/plants
        createVegetation()

        // Add city props (benches, trash cans, etc)
        createCityProps()

        // Setup camera with better settings
        let camera = SCNCamera()
        camera.fieldOfView = 60
        camera.zNear = 0.1
        camera.zFar = 1000
        camera.wantsDepthOfField = true
        camera.focalLength = 50
        camera.fStop = 2.8
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        scene.rootNode.addChildNode(cameraNode)

        // Create cat node
        catNode = createCatNode()
        catNode?.position = SCNVector3(x: 0, y: 0.5, z: 0)
        scene.rootNode.addChildNode(catNode!)

        // Enhanced lighting setup
        setupLighting()
    }

    private func setupLighting() {
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = NSColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
        ambientLight.light!.intensity = 200
        scene.rootNode.addChildNode(ambientLight)

        // Add main directional light (sun)
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light!.type = .directional
        sunLight.light!.color = NSColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
        sunLight.light!.intensity = 1000
        sunLight.light!.castsShadow = true
        sunLight.light!.shadowMode = .deferred
        sunLight.light!.shadowSampleCount = 16
        sunLight.position = SCNVector3(x: 10, y: 20, z: 10)
        sunLight.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(sunLight)

        // Add fill light
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light!.type = .omni
        fillLight.light!.color = NSColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
        fillLight.light!.intensity = 300
        fillLight.position = SCNVector3(x: -5, y: 5, z: -5)
        scene.rootNode.addChildNode(fillLight)
    }

    private func createStreetGrid() {
        // Create street lines
        for i in -5...5 {
            let lineGeometry = SCNBox(width: 0.1, height: 0.01, length: 100, chamferRadius: 0)
            lineGeometry.firstMaterial?.diffuse.contents = NSColor.white.withAlphaComponent(0.3)
            let line = SCNNode(geometry: lineGeometry)
            line.position = SCNVector3(x: CGFloat(i * 10), y: 0.01, z: 0)
            scene.rootNode.addChildNode(line)
        }

        for i in -5...5 {
            let lineGeometry = SCNBox(width: 100, height: 0.01, length: 0.1, chamferRadius: 0)
            lineGeometry.firstMaterial?.diffuse.contents = NSColor.white.withAlphaComponent(0.3)
            let line = SCNNode(geometry: lineGeometry)
            line.position = SCNVector3(x: 0, y: 0.01, z: CGFloat(i * 10))
            scene.rootNode.addChildNode(line)
        }
    }

    private func createBuildings() {
        let buildingPositions = [
            (x: -20, z: -20, w: 8, h: 15, d: 8),
            (x: 20, z: -20, w: 10, h: 20, d: 10),
            (x: -20, z: 20, w: 6, h: 12, d: 6),
            (x: 20, z: 20, w: 8, h: 18, d: 8),
            (x: -35, z: 0, w: 7, h: 16, d: 7),
            (x: 35, z: 0, w: 9, h: 14, d: 9),
        ]

        for (x, z, width, height, depth) in buildingPositions {
            let building = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(depth), chamferRadius: 0.2)

            // Building material
            building.firstMaterial?.diffuse.contents = NSColor(
                red: CGFloat.random(in: 0.6...0.8),
                green: CGFloat.random(in: 0.6...0.8),
                blue: CGFloat.random(in: 0.6...0.8),
                alpha: 1.0
            )
            building.firstMaterial?.roughness.contents = 0.7
            building.firstMaterial?.metalness.contents = 0.2

            let buildingNode = SCNNode(geometry: building)
            buildingNode.position = SCNVector3(x: CGFloat(x), y: CGFloat(height) / 2, z: CGFloat(z))
            scene.rootNode.addChildNode(buildingNode)

            // Add windows
            addWindows(to: buildingNode, width: width, height: height, depth: depth)
        }
    }

    private func addWindows(to building: SCNNode, width: Int, height: Int, depth: Int) {
        let windowSize: CGFloat = 0.4
        let windowSpacing: CGFloat = 1.0

        // Front windows
        for row in 1..<height {
            for col in 0..<(width - 1) {
                let window = SCNBox(width: windowSize, height: windowSize, length: 0.05, chamferRadius: 0.02)
                let isLit = Bool.random()
                window.firstMaterial?.diffuse.contents = isLit ? NSColor.yellow : NSColor.darkGray
                window.firstMaterial?.emission.contents = isLit ? NSColor.yellow.withAlphaComponent(0.5) : NSColor.clear

                let windowNode = SCNNode(geometry: window)
                windowNode.position = SCNVector3(
                    x: CGFloat(col - (width / 2)) * windowSpacing,
                    y: CGFloat(row - (height / 2)) * windowSpacing,
                    z: CGFloat(depth) / 2 + 0.05
                )
                building.addChildNode(windowNode)
            }
        }
    }

    private func createVegetation() {
        // Add trees/plants around the city
        let treePositions = [
            (-15, -15), (15, -15), (-15, 15), (15, 15),
            (-10, 0), (10, 0), (0, -10), (0, 10),
            (-25, -10), (25, -10), (-25, 10), (25, 10)
        ]

        for (x, z) in treePositions {
            let tree = createTree()
            tree.position = SCNVector3(x: CGFloat(x), y: 0, z: CGFloat(z))
            scene.rootNode.addChildNode(tree)
        }
    }

    private func createTree() -> SCNNode {
        let treeNode = SCNNode()

        // Trunk
        let trunk = SCNCylinder(radius: 0.2, height: 2)
        trunk.firstMaterial?.diffuse.contents = NSColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1.0)
        let trunkNode = SCNNode(geometry: trunk)
        trunkNode.position = SCNVector3(x: 0, y: 1, z: 0)
        treeNode.addChildNode(trunkNode)

        // Foliage
        let foliage = SCNSphere(radius: 1.2)
        foliage.firstMaterial?.diffuse.contents = NSColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
        foliage.firstMaterial?.roughness.contents = 0.9
        let foliageNode = SCNNode(geometry: foliage)
        foliageNode.position = SCNVector3(x: 0, y: 2.5, z: 0)
        treeNode.addChildNode(foliageNode)

        return treeNode
    }

    private func createCityProps() {
        // Add benches
        for i in 0..<4 {
            let bench = createBench()
            let angle = CGFloat(i) * .pi / 2
            bench.position = SCNVector3(x: cos(angle) * 12, y: 0, z: sin(angle) * 12)
            bench.eulerAngles = SCNVector3(x: 0, y: angle + .pi / 2, z: 0)
            scene.rootNode.addChildNode(bench)
        }

        // Add lamp posts
        for i in 0..<8 {
            let lamp = createLampPost()
            let angle = CGFloat(i) * .pi / 4
            lamp.position = SCNVector3(x: cos(angle) * 18, y: 0, z: sin(angle) * 18)
            scene.rootNode.addChildNode(lamp)
        }
    }

    private func createBench() -> SCNNode {
        let benchNode = SCNNode()

        // Seat
        let seat = SCNBox(width: 1.5, height: 0.1, length: 0.5, chamferRadius: 0.02)
        seat.firstMaterial?.diffuse.contents = NSColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0)
        let seatNode = SCNNode(geometry: seat)
        seatNode.position = SCNVector3(x: 0, y: 0.4, z: 0)
        benchNode.addChildNode(seatNode)

        // Back
        let back = SCNBox(width: 1.5, height: 0.5, length: 0.1, chamferRadius: 0.02)
        back.firstMaterial?.diffuse.contents = NSColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0)
        let backNode = SCNNode(geometry: back)
        backNode.position = SCNVector3(x: 0, y: 0.65, z: -0.25)
        benchNode.addChildNode(backNode)

        return benchNode
    }

    private func createLampPost() -> SCNNode {
        let lampNode = SCNNode()

        // Post
        let post = SCNCylinder(radius: 0.08, height: 4)
        post.firstMaterial?.diffuse.contents = NSColor.darkGray
        post.firstMaterial?.metalness.contents = 0.8
        let postNode = SCNNode(geometry: post)
        postNode.position = SCNVector3(x: 0, y: 2, z: 0)
        lampNode.addChildNode(postNode)

        // Light fixture
        let fixture = SCNSphere(radius: 0.3)
        fixture.firstMaterial?.diffuse.contents = NSColor.white
        fixture.firstMaterial?.emission.contents = NSColor.yellow
        let fixtureNode = SCNNode(geometry: fixture)
        fixtureNode.position = SCNVector3(x: 0, y: 4, z: 0)
        lampNode.addChildNode(fixtureNode)

        // Add actual light source
        let light = SCNLight()
        light.type = .omni
        light.color = NSColor.yellow
        light.intensity = 500
        light.attenuationStartDistance = 5
        light.attenuationEndDistance = 15
        fixtureNode.light = light

        return lampNode
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

    func updateCollectables(_ collectables: [Collectable]) {
        // Remove collected items
        for (id, node) in collectableNodes {
            if let collectable = collectables.first(where: { $0.id == id }) {
                if collectable.isCollected {
                    node.removeFromParentNode()
                    collectableNodes.removeValue(forKey: id)
                }
            }
        }

        // Add new collectables
        for collectable in collectables where !collectable.isCollected {
            if collectableNodes[collectable.id] == nil {
                let node = createCollectableNode(collectable: collectable)
                node.position = SCNVector3(
                    x: CGFloat(collectable.position.x),
                    y: 0.5,
                    z: CGFloat(collectable.position.y)
                )
                scene.rootNode.addChildNode(node)
                collectableNodes[collectable.id] = node

                // Add floating animation
                let floatAction = SCNAction.sequence([
                    SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 1.0),
                    SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 1.0)
                ])
                node.runAction(SCNAction.repeatForever(floatAction))

                // Add rotation animation
                let rotateAction = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 3.0)
                node.runAction(SCNAction.repeatForever(rotateAction))
            }
        }
    }

    func updateInteractiveObjects(_ objects: [InteractiveObject]) {
        // Remove or update interactive objects
        for object in objects {
            if interactiveObjectNodes[object.id] == nil {
                let node = createInteractiveObjectNode(object: object)
                node.position = SCNVector3(
                    x: CGFloat(object.position.x),
                    y: 0.5,
                    z: CGFloat(object.position.y)
                )
                scene.rootNode.addChildNode(node)
                interactiveObjectNodes[object.id] = node
            }
        }
    }

    private func createCollectableNode(collectable: Collectable) -> SCNNode {
        let node = SCNNode()

        switch collectable.type {
        case .shiny:
            // Create sparkling gem
            let gem = SCNSphere(radius: 0.25)
            gem.firstMaterial?.diffuse.contents = NSColor.yellow
            gem.firstMaterial?.emission.contents = NSColor.yellow.withAlphaComponent(0.6)
            gem.firstMaterial?.metalness.contents = 1.0
            gem.firstMaterial?.roughness.contents = 0.2
            node.geometry = gem

        case .fish:
            // Create fish shape
            let body = SCNBox(width: 0.4, height: 0.2, length: 0.6, chamferRadius: 0.1)
            body.firstMaterial?.diffuse.contents = NSColor.systemBlue
            body.firstMaterial?.metalness.contents = 0.5
            let bodyNode = SCNNode(geometry: body)
            node.addChildNode(bodyNode)

            // Tail
            let tail = SCNCone(topRadius: 0, bottomRadius: 0.2, height: 0.3)
            tail.firstMaterial?.diffuse.contents = NSColor.systemBlue
            let tailNode = SCNNode(geometry: tail)
            tailNode.position = SCNVector3(x: 0, y: 0, z: -0.4)
            tailNode.eulerAngles = SCNVector3(x: .pi / 2, y: 0, z: 0)
            node.addChildNode(tailNode)

        case .feather:
            // Create feather
            let feather = SCNBox(width: 0.1, height: 0.6, length: 0.05, chamferRadius: 0.02)
            feather.firstMaterial?.diffuse.contents = NSColor.systemPink
            feather.firstMaterial?.transparency = 0.8
            node.geometry = feather

        case .hat:
            // Create hat (top hat shape)
            let brim = SCNCylinder(radius: 0.35, height: 0.05)
            brim.firstMaterial?.diffuse.contents = NSColor.black
            let brimNode = SCNNode(geometry: brim)
            brimNode.position = SCNVector3(x: 0, y: 0, z: 0)
            node.addChildNode(brimNode)

            let top = SCNCylinder(radius: 0.25, height: 0.4)
            top.firstMaterial?.diffuse.contents = NSColor.black
            let topNode = SCNNode(geometry: top)
            topNode.position = SCNVector3(x: 0, y: 0.225, z: 0)
            node.addChildNode(topNode)
        }

        return node
    }

    private func createInteractiveObjectNode(object: InteractiveObject) -> SCNNode {
        let node = SCNNode()

        switch object.type {
        case .box:
            let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.05)
            box.firstMaterial?.diffuse.contents = NSColor.brown
            box.firstMaterial?.roughness.contents = 0.8
            node.geometry = box

        case .trashCan:
            let can = SCNCylinder(radius: 0.4, height: 1.0)
            can.firstMaterial?.diffuse.contents = NSColor.darkGray
            can.firstMaterial?.metalness.contents = 0.7
            node.geometry = can

        case .vase:
            let vase = SCNCylinder(radius: 0.3, height: 0.8)
            vase.firstMaterial?.diffuse.contents = NSColor.systemTeal
            vase.firstMaterial?.metalness.contents = 0.3
            node.geometry = vase

        case .person:
            // Simple person representation
            let body = SCNCapsule(capRadius: 0.3, height: 1.5)
            body.firstMaterial?.diffuse.contents = NSColor.systemIndigo
            let bodyNode = SCNNode(geometry: body)
            bodyNode.position = SCNVector3(x: 0, y: 0.75, z: 0)
            node.addChildNode(bodyNode)

            let head = SCNSphere(radius: 0.25)
            head.firstMaterial?.diffuse.contents = NSColor.systemOrange
            let headNode = SCNNode(geometry: head)
            headNode.position = SCNVector3(x: 0, y: 1.7, z: 0)
            node.addChildNode(headNode)

        case .bird:
            // Simple bird
            let body = SCNSphere(radius: 0.2)
            body.firstMaterial?.diffuse.contents = NSColor.systemRed
            node.geometry = body

        case .foodStall:
            // Food stall
            let stall = SCNBox(width: 2.0, height: 1.5, length: 1.0, chamferRadius: 0.1)
            stall.firstMaterial?.diffuse.contents = NSColor.systemOrange
            node.geometry = stall
        }

        return node
    }

    private var collectables: [Collectable] = []
    private var interactiveObjects: [InteractiveObject] = []

    func startUpdateLoop(catController: CatController, cameraController: CameraController, networkManager: NetworkManager, collectables: [Collectable], interactiveObjects: [InteractiveObject]) {
        self.catController = catController
        self.cameraController = cameraController
        self.networkManager = networkManager
        self.collectables = collectables
        self.interactiveObjects = interactiveObjects

        // Initial setup of collectables and objects
        updateCollectables(collectables)
        updateInteractiveObjects(interactiveObjects)
    }

    func stopUpdateLoop() {
        catController = nil
        cameraController = nil
        networkManager = nil
    }

    func updateCollectablesData(_ collectables: [Collectable]) {
        self.collectables = collectables
    }

    func updateInteractiveObjectsData(_ objects: [InteractiveObject]) {
        self.interactiveObjects = objects
    }

    // SCNSceneRendererDelegate method - called every frame
    nonisolated func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        Task { @MainActor in
            guard let catController = catController,
                  let cameraController = cameraController,
                  let networkManager = networkManager else { return }

            updateCatPosition(catController.position)
            updateCamera(cameraController.position, lookAt: cameraController.lookAt)
            updateNetworkPlayers(networkManager.connectedPlayers)
            updateCollectables(collectables)
            updateInteractiveObjects(interactiveObjects)
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
            options: [.autoenablesDefaultLighting, .temporalAntialiasingEnabled],
            delegate: sceneManager
        )
        .onAppear {
            sceneManager.setupScene()
            sceneManager.startUpdateLoop(
                catController: catController,
                cameraController: cameraController,
                networkManager: networkManager,
                collectables: collectables,
                interactiveObjects: interactiveObjects
            )
        }
        .onChange(of: collectables) { _, newValue in
            sceneManager.updateCollectablesData(newValue)
        }
        .onChange(of: interactiveObjects) { _, newValue in
            sceneManager.updateInteractiveObjectsData(newValue)
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
