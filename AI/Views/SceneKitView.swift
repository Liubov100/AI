import SwiftUI
import SceneKit

// A simple SceneKit bridge for SwiftUI that renders basic 3D nodes
struct SceneKitView: UIViewRepresentable {
    @Binding var collectables: [Collectable]
    @Binding var npcs: [NPC]
    @Binding var interactiveObjects: [InteractiveObject]
    @Binding var catPosition: CGPoint

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = SCNScene()
        scnView.allowsCameraControl = false
        scnView.backgroundColor = .clear
        context.coordinator.setupScene(scene: scnView.scene!)
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
        var collectableNodes: [String: SCNNode] = [:]
        var npcNodes: [String: SCNNode] = [:]
        var interactiveNodes: [String: SCNNode] = [:]
        var catNode: SCNNode?

        func setupScene(scene: SCNScene) {
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

            // Simple cat node
            let catGeometry = SCNSphere(radius: 16)
            catGeometry.firstMaterial?.diffuse.contents = UIColor.black
            let cat = SCNNode(geometry: catGeometry)
            cat.position = SCNVector3(0, 0, 0)
            scene.rootNode.addChildNode(cat)
            catNode = cat
        }

        func updateNodes(collectables: [Collectable], npcs: [NPC], interactiveObjects: [InteractiveObject], catPosition: CGPoint) {
            guard let scene = cameraNode.scene else { return }

            // Update cat
            if let cat = catNode {
                cat.position = SCNVector3(Float(catPosition.x), Float(-catPosition.y), 0)
            }

            // Update collectables
            for c in collectables where !c.isCollected {
                if collectableNodes[c.id] == nil {
                    let geo = SCNSphere(radius: 8)
                    geo.firstMaterial?.diffuse.contents = UIColor.yellow
                    let node = SCNNode(geometry: geo)
                    node.name = c.id
                    node.position = SCNVector3(Float(c.position.x), Float(-c.position.y), 0)
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
                    let geo = SCNBox(width: 20, height: 30, length: 8, chamferRadius: 2)
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
                    scene.rootNode.addChildNode(node)
                    interactiveNodes[obj.id] = node
                } else {
                    interactiveNodes[obj.id]?.position = SCNVector3(Float(obj.position.x), Float(-obj.position.y), 0)
                }
            }
        }
    }
}
