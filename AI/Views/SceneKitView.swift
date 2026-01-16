import SwiftUI
import SceneKit

#if canImport(UIKit)
import UIKit

// A simple SceneKit bridge for SwiftUI that renders basic 3D nodes (iOS/tvOS)
struct SceneKitView: UIViewRepresentable {
    @Binding var collectables: [Collectable]
    @Binding var npcs: [NPC]
    @Binding var interactiveObjects: [InteractiveObject]
    @Binding var catPosition: CGPoint

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        let scene = SCNScene()
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.backgroundColor = .clear
        context.coordinator.scene = scene
        context.coordinator.setupScene(scene: scene)
        scnView.pointOfView = context.coordinator.cameraNode
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.updateNodes(collectables: collectables, npcs: npcs, interactiveObjects: interactiveObjects, catPosition: catPosition)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        let cameraNode = SCNNode()
        var scene: SCNScene?
        var collectableNodes: [String: SCNNode] = [:]
        var npcNodes: [String: SCNNode] = [:]
        var interactiveNodes: [String: SCNNode] = [:]
        var catNode: SCNNode?

        func setupScene(scene: SCNScene) {
            self.scene = scene
            // Camera
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(0, 0, 600)
            scene.rootNode.addChildNode(cameraNode)

            // Ambient light
            let ambient = SCNLight()
            ambient.type = .ambient
            ambient.color = UIColor(white: 0.6, alpha: 1.0)
            let ambientNode = SCNNode()
            ambientNode.light = ambient
            scene.rootNode.addChildNode(ambientNode)

            // Floor (invisible, for shadows if needed)
            let floor = SCNFloor()
            let floorNode = SCNNode(geometry: floor)
            floorNode.opacity = 0.0
            scene.rootNode.addChildNode(floorNode)

            // Simple cat node (composite)
            let body = SCNCapsule(capRadius: 10, height: 24)
            body.firstMaterial?.diffuse.contents = UIColor.black
            let bodyNode = SCNNode(geometry: body)
            bodyNode.position = SCNVector3(0, 0, 0)

            let head = SCNSphere(radius: 8)
            head.firstMaterial?.diffuse.contents = UIColor.black
            let headNode = SCNNode(geometry: head)
            headNode.position = SCNVector3(0, 12, 0)

            let cat = SCNNode()
            cat.addChildNode(bodyNode)
            cat.addChildNode(headNode)
            scene.rootNode.addChildNode(cat)
            catNode = cat
        }

        func updateNodes(collectables: [Collectable], npcs: [NPC], interactiveObjects: [InteractiveObject], catPosition: CGPoint) {
            guard let scene = self.scene else { return }

            // Update cat
            if let cat = catNode {
                cat.position = SCNVector3(Float(catPosition.x), Float(-catPosition.y), 0)
            }

            // Update collectables
            for c in collectables where !c.isCollected {
                if collectableNodes[c.id] == nil {
                    // Use a torus for shinies for a nicer 3D look
                    let geo = SCNTorus(ringRadius: 10, pipeRadius: 3)
                    geo.firstMaterial?.diffuse.contents = UIColor.yellow
                    geo.firstMaterial?.emission.contents = UIColor.white
                    let node = SCNNode(geometry: geo)
                    node.name = c.id
                    node.position = SCNVector3(Float(c.position.x), Float(-c.position.y), 0)

                    // Add rotation and bobbing
                    let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 2)
                    let spin = SCNAction.repeatForever(rotate)
                    let bobUp = SCNAction.moveBy(x: 0, y: 4, z: 0, duration: 0.8)
                    bobUp.timingMode = .easeInEaseOut
                    let bob = SCNAction.sequence([bobUp, bobUp.reversed()])
                    let bobbing = SCNAction.repeatForever(bob)
                    node.runAction(spin)
                    node.runAction(bobbing)

                    scene.rootNode.addChildNode(node)
                    collectableNodes[c.id] = node
                } else {
                    collectableNodes[c.id]?.position = SCNVector3(Float(c.position.x), Float(-c.position.y), 0)
                }
            }

            // Remove collected nodes
            let existingIDs = Set(collectables.map { $0.id })
            for (id, node) in collectableNodes where !existingIDs.contains(id) || (collectables.first { $0.id == id }?.isCollected ?? true) {
                node.removeFromParentNode()
                collectableNodes.removeValue(forKey: id)
            }

            // NPCs (simple boxes)
            for n in npcs {
                if npcNodes[n.id] == nil {
                    let geo = SCNCylinder(radius: 8, height: 24)
                    geo.firstMaterial?.diffuse.contents = UIColor.brown
                    let node = SCNNode(geometry: geo)
                    node.name = n.id
                    node.position = SCNVector3(Float(n.position.x), Float(-n.position.y), 0)
                    scene.rootNode.addChildNode(node)
                    npcNodes[n.id] = node
                } else {
                    npcNodes[n.id]?.position = SCNVector3(Float(n.position.x), Float(-n.position.y), 0)
                }
            }

            // Interactive objects
            for obj in interactiveObjects {
                if interactiveNodes[obj.id] == nil {
                    let geo = SCNBox(width: 18, height: 18, length: 18, chamferRadius: 1)
                    geo.firstMaterial?.diffuse.contents = UIColor.gray
                    let node = SCNNode(geometry: geo)
                    node.name = obj.id
                    node.position = SCNVector3(Float(obj.position.x), Float(-obj.position.y), 0)

                    // subtle scale pulse
                    let pulseUp = SCNAction.scale(to: 1.08, duration: 0.6)
                    let pulseDown = SCNAction.scale(to: 1.0, duration: 0.6)
                    let pulse = SCNAction.repeatForever(SCNAction.sequence([pulseUp, pulseDown]))
                    node.runAction(pulse)

                    scene.rootNode.addChildNode(node)
                    interactiveNodes[obj.id] = node
                } else {
                    interactiveNodes[obj.id]?.position = SCNVector3(Float(obj.position.x), Float(-obj.position.y), 0)
                }
            }
        }
    }
}
#elseif canImport(AppKit)
import AppKit

// A simple SceneKit bridge for SwiftUI that renders basic 3D nodes (macOS)
struct SceneKitView: NSViewRepresentable {
    @Binding var collectables: [Collectable]
    @Binding var npcs: [NPC]
    @Binding var interactiveObjects: [InteractiveObject]
    @Binding var catPosition: CGPoint

    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        let scene = SCNScene()
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.backgroundColor = .clear
        context.coordinator.scene = scene
        context.coordinator.setupScene(scene: scene)
        scnView.pointOfView = context.coordinator.cameraNode
        return scnView
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        context.coordinator.updateNodes(collectables: collectables, npcs: npcs, interactiveObjects: interactiveObjects, catPosition: catPosition)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        let cameraNode = SCNNode()
        var scene: SCNScene?
        var collectableNodes: [String: SCNNode] = [:]
        var npcNodes: [String: SCNNode] = [:]
        var interactiveNodes: [String: SCNNode] = [:]
        var catNode: SCNNode?

        func setupScene(scene: SCNScene) {
            self.scene = scene
            // Camera
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(0, 0, 600)
            scene.rootNode.addChildNode(cameraNode)

            // Ambient light
            let ambient = SCNLight()
            ambient.type = .ambient
            ambient.color = NSColor(white: 0.6, alpha: 1.0)
            let ambientNode = SCNNode()
            ambientNode.light = ambient
            scene.rootNode.addChildNode(ambientNode)

            // Floor (invisible, for shadows if needed)
            let floor = SCNFloor()
            let floorNode = SCNNode(geometry: floor)
            floorNode.opacity = 0.0
            scene.rootNode.addChildNode(floorNode)

            // Simple cat node (composite)
            let body = SCNCapsule(capRadius: 10, height: 24)
            body.firstMaterial?.diffuse.contents = NSColor.black
            let bodyNode = SCNNode(geometry: body)
            bodyNode.position = SCNVector3(0, 0, 0)

            let head = SCNSphere(radius: 8)
            head.firstMaterial?.diffuse.contents = NSColor.black
            let headNode = SCNNode(geometry: head)
            headNode.position = SCNVector3(0, 12, 0)

            let cat = SCNNode()
            cat.addChildNode(bodyNode)
            cat.addChildNode(headNode)
            scene.rootNode.addChildNode(cat)
            catNode = cat
        }

        func updateNodes(collectables: [Collectable], npcs: [NPC], interactiveObjects: [InteractiveObject], catPosition: CGPoint) {
            guard let scene = self.scene else { return }

            // Update cat
            if let cat = catNode {
                cat.position = SCNVector3(Float(catPosition.x), Float(-catPosition.y), 0)
            }

            // Update collectables
            for c in collectables where !c.isCollected {
                if collectableNodes[c.id] == nil {
                    let geo = SCNTorus(ringRadius: 10, pipeRadius: 3)
                    geo.firstMaterial?.diffuse.contents = NSColor.yellow
                    geo.firstMaterial?.emission.contents = NSColor.white
                    let node = SCNNode(geometry: geo)
                    node.name = c.id
                    node.position = SCNVector3(Float(c.position.x), Float(-c.position.y), 0)

                    let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 2)
                    let spin = SCNAction.repeatForever(rotate)
                    let bobUp = SCNAction.moveBy(x: 0, y: 4, z: 0, duration: 0.8)
                    bobUp.timingMode = .easeInEaseOut
                    let bob = SCNAction.sequence([bobUp, bobUp.reversed()])
                    let bobbing = SCNAction.repeatForever(bob)
                    node.runAction(spin)
                    node.runAction(bobbing)

                    scene.rootNode.addChildNode(node)
                    collectableNodes[c.id] = node
                } else {
                    collectableNodes[c.id]?.position = SCNVector3(Float(c.position.x), Float(-c.position.y), 0)
                }
            }

            // Remove collected nodes
            let existingIDs = Set(collectables.map { $0.id })
            for (id, node) in collectableNodes where !existingIDs.contains(id) || (collectables.first { $0.id == id }?.isCollected ?? true) {
                node.removeFromParentNode()
                collectableNodes.removeValue(forKey: id)
            }

            // NPCs (simple boxes)
            for n in npcs {
                if npcNodes[n.id] == nil {
                    let geo = SCNCylinder(radius: 8, height: 24)
                    geo.firstMaterial?.diffuse.contents = NSColor.brown
                    let node = SCNNode(geometry: geo)
                    node.name = n.id
                    node.position = SCNVector3(Float(n.position.x), Float(-n.position.y), 0)
                    scene.rootNode.addChildNode(node)
                    npcNodes[n.id] = node
                } else {
                    npcNodes[n.id]?.position = SCNVector3(Float(n.position.x), Float(-n.position.y), 0)
                }
            }

            // Interactive objects
            for obj in interactiveObjects {
                if interactiveNodes[obj.id] == nil {
                    let geo = SCNBox(width: 18, height: 18, length: 18, chamferRadius: 1)
                    geo.firstMaterial?.diffuse.contents = NSColor.gray
                    let node = SCNNode(geometry: geo)
                    node.name = obj.id
                    node.position = SCNVector3(Float(obj.position.x), Float(-obj.position.y), 0)

                    let pulseUp = SCNAction.scale(to: 1.08, duration: 0.6)
                    let pulseDown = SCNAction.scale(to: 1.0, duration: 0.6)
                    let pulse = SCNAction.repeatForever(SCNAction.sequence([pulseUp, pulseDown]))
                    node.runAction(pulse)

                    scene.rootNode.addChildNode(node)
                    interactiveNodes[obj.id] = node
                } else {
                    interactiveNodes[obj.id]?.position = SCNVector3(Float(obj.position.x), Float(-obj.position.y), 0)
                }
            }
        }
    }
}
#endif

