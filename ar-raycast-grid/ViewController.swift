//
//  ViewController.swift
//  ar-memory-game
//
//  Created by Sebastiaan Hols on 06/04/2020.
//  Copyright © 2020 Sebastiaan Hols. All rights reserved.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        // Get the entity at the location we've tapped, if one exists
        if let card = arView.entity(at: tapLocation) {
            // For testing purposes, print the name of the tapped entity
            print("Card hit! \(card.name)")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an anchor plane for the game
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        arView.scene.addAnchor(anchor)
        
        // Setup tap recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(onTap))
        arView.addGestureRecognizer(tapGesture)
        
        // Create card templates
        var cardTemplates: [Entity] = []
        
        for index in 1...8 {
            let assetName = "memory_card_\(index)"
            let cardTemplate = try! Entity.loadModel(named: assetName)
            cardTemplate.generateCollisionShapes(recursive: true)
            cardTemplate.name = assetName
            cardTemplates.append(cardTemplate)
        }
        
        // Clone and create the cards
        var cards: [Entity] = []
        
        for cardTemplate in cardTemplates {
            for _ in 1...2 {
                cards.append(cardTemplate.clone(recursive: true))
            }
        }
        
        cards.shuffle()
        
        // Place the cards
        
        for (index, card) in cards.enumerated(){
            
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            
            card.position = [x * 0.1, 0, z * 0.1]
            card.setScale(SIMD3(repeating: Float(0.0015)), relativeTo: anchor)
            
            
            // Setup animation
            var flipDownTransform = card.transform
            flipDownTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
            
            let flipDownController = card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeOut)
            
            
            // Todo: Setup flip animation 12:51
            
            
            anchor.addChild(card)
            
        }
        
    }
}
