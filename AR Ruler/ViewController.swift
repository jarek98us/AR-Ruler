//
//  ViewController.swift
//  AR Ruler
//
//  Created by Jarek on 28/03/2018.
//  Copyright © 2018 Jarek. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let node = SCNNode()
        
        node.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z)
        
        node.geometry = dotGeometry
        
        sceneView.scene.rootNode.addChildNode(node)
        dotNodes.append(node)

        if dotNodes.count >= 2 {
            calculateDistance(to: dotNodes.count - 1)
        }
        // sceneView.autoenablesDefaultLighting = true
    }
    
    func calculateDistance(to nodeIdx: Int) {
        let start = dotNodes[nodeIdx - 1].position
        let end = dotNodes[nodeIdx].position
        
        let distance = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2) + pow(end.z - start.z, 2)) * 100
        print("start: \(start)")
        print("end: \(end)")
        let distanceText = String(format: "%.2f", distance) + " cm"
        displayText(text: distanceText, at: end)
    }
    
    func displayText(text: String, at position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        textNodes.append(textNode)
    }
    
    @IBAction func cleanButtonPressed(_ sender: UIBarButtonItem) {
        for node in dotNodes {
            node.removeFromParentNode()
        }
        
        for node in textNodes {
            node.removeFromParentNode()
        }
        
        dotNodes.removeAll()
        textNodes.removeAll()
    }
}
