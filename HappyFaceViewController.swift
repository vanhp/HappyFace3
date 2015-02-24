//
//  HappyFaceViewController.swift
//  HappyFace3
//
//  Created by Vanh Phom on 2/16/15.
//  Copyright (c) 2015 VSP inc. All rights reserved.
//

import UIKit

class HappyFaceViewController: UIViewController,FaceViewDataSource {
    
//    //tie to the view to the model inside the controller
    @IBOutlet weak var faceView: FaceView! {
        didSet{ faceView.dataSource = self
        // add gesture to view
        faceView.addGestureRecognizer(UIPinchGestureRecognizer(target:faceView, action: "scale:"))
//
//        //add panning gesture by code or in storyboard
//        faceView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "changeHappiness:"))
        }
    }

    private struct Constants {
        static let HappinessGestureScale: CGFloat = 4
    }
    
    @IBAction func panHappy(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            case .Ended: fallthrough
            case .Changed:
                    let translation = sender.translationInView(faceView)
                    let happinessChange = -Int(translation.y / Constants.HappinessGestureScale)
                    if happinessChange != 0 {
                        happiness += happinessChange
                        sender.setTranslation(CGPointZero, inView: faceView)//reset get delta
                        println("happiness = \(happiness)")
                    }
            default: break
            }
        
    }
//    
//    func changeHappiness(gesture: UIPanGestureRecognizer) {
//       switch gesture.state {
//        case .Ended: fallthrough
//        case .Changed:
//            //translate into faceview coord sys
//            let translation = gesture.translationInView(faceView)
//            let happinessChange = -Int(translation.y / Constants.HappinessGestureScale)
//            if happinessChange != 0 {
//                happiness += happinessChange
//                gesture.setTranslation(CGPointZero, inView: faceView)//reset get inc
//                
//                println("changehappiness = \(happiness)")
//            }
//        default: break
//        }
//    }
//    
    
    //model
    var happiness: Int = 100 { //0 sad,100 ecstatitc
        //property observer
        didSet {happiness = min(max(happiness,0),100)
         //   println("happiness = \(happiness)")
            updateUI()
        }
        
    }
    
    func updateUI(){
        faceView.setNeedsDisplay()
    }
    
    func smilinessForFaceView(sender: FaceView) -> Double? {
        return Double(happiness - 50) / 50
    }
}
