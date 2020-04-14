//
//  ViewController.swift
//  ar-memory-game
//
//  Created by Sebastiaan Hols on 06/04/2020.
//  Copyright © 2020 Sebastiaan Hols. All rights reserved.
//
// https://www.youtube.com/watch?v=Qtm75FuCrF0

import UIKit
import RealityKit

// MARK: Extracting Custom Entity

struct CardComponent : Component, Codable {
    var revealed = false
    var kind = ""
}

class CardEntity : Entity, HasModel, HasCollision {
    public var card: CardComponent {
        get {return components[CardComponent.self] ?? CardComponent()}
        set { components[CardComponent.self] = newValue}
    }
}

// MARK: Working code

let big = SIMD3(repeating: Float(0.015))
let small = SIMD3(repeating: Float(0.003))

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        // Get the entity at the location we've tapped, if one exists
        if let card = arView.entity(at: tapLocation) {
            
            // Setup animation
            var flipDownTransform = card.transform
            
            flipDownTransform.scale = card.transform.scale == big ? small : big
            
            let flipDownController = card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeOut)
            
            flipDownController.resume()
            
            print("Card hit! \(card.name)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup tap recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(onTap))
        arView.addGestureRecognizer(tapGesture)
        
        // Create an anchor plane for the game
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        arView.scene.addAnchor(anchor)
        
        // Create card templates
        var cardTemplates: [Entity] = []
        
        for index in 1...8 {
            let assetName = "memory_card_\(index)"
            let cardTemplate = try! Entity.loadModel(named: assetName)
            arView.installGestures([.rotation, .translation], for: cardTemplate)
            cardTemplate.generateCollisionShapes(recursive: true)
            cardTemplate.name = assetName
            cardTemplates.append(cardTemplate)
        }
        
        // Clone and create the cards
        var cards: [Entity] = []
        
        for cardTemplate in cardTemplates {
//            Uncomment for duplicates
//            for _ in 1...2 {
//                cards.append(cardTemplate.clone(recursive: true))
                cards.append(cardTemplate)
//            }
        }
        
        cards.shuffle()
        
        // Place the cards
        
        for (index, card) in cards.enumerated(){
            
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            
            card.position = [x * 0.1, 0, z * 0.1]
            card.setScale(small, relativeTo: anchor)
            
            anchor.addChild(card)
            
        }
        
    }
}
