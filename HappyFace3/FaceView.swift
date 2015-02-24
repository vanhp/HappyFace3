//
//  FaceView.swift
//  HappyFace3
//
//  Created by Vanh Phom on 2/16/15.
//  Copyright (c) 2015 VSP inc. All rights reserved.
//

import UIKit


//protocol only implementable by class
protocol FaceViewDataSource:class{
    //delegate (event)
    func smilinessForFaceView(sender:FaceView)->Double?
}



@IBDesignable
class FaceView: UIView {
    
    
    @IBInspectable  // make it changeable inUI
    var lineWidth:CGFloat = 3 {didSet{setNeedsDisplay()}}
    @IBInspectable                                      // property observer
    var color:UIColor = UIColor.blueColor() {didSet{setNeedsDisplay()}}
   // @IBInspectable
    var scale:CGFloat = 0.90 {didSet{setNeedsDisplay()}}
    //    @IBInspectable
    //converto parent center
    var faceCenter:CGPoint {return convertPoint(center, fromView: superview)}
    
    @IBInspectable
    var faceRadius:CGFloat  {return min(bounds.size.width,bounds.size.height) / 2 * scale}//0.90}
    
    //weak (point) allow the object to unload from mem
    weak var dataSource: FaceViewDataSource?
    
        //constants
        private struct Scaling {
            static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
            static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
            static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
            static let FaceRadiusToMouthWidthRatio: CGFloat = 1
            static let FaceRadiusToMouthHeightRatio: CGFloat = 3
            static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
        }
        private enum Eye{ case Left,Right}
    
        private func bezierPathForEye (whichEye: Eye) -> UIBezierPath {
            let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
            let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
            let eyeHorizonTalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
    
            var eyeCenter = faceCenter
            eyeCenter.y -= eyeVerticalOffset
            switch whichEye {
            case .Left: eyeCenter.x -= eyeHorizonTalSeparation / 2
            case .Right: eyeCenter.x += eyeHorizonTalSeparation / 2
            }
            let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
            path.lineWidth = lineWidth
            return path
        }
    
        private func bezierPathForSmile(fractionOfMaxSmile:Double) -> UIBezierPath {
            let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
            let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
            let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
            let smileHeight = CGFloat(max(min(fractionOfMaxSmile,1),-1)) * mouthHeight
            let start = CGPoint(x:faceCenter.x - mouthWidth / 2, y:faceCenter.y + mouthVerticalOffset)
            let end = CGPoint(x: start.x + mouthWidth, y:start.y)
            let cp1 = CGPoint(x: start.x + mouthWidth / 3 , y:start.y + smileHeight)
            let cp2 = CGPoint(x: end.x - mouthWidth / 3, y:cp1.y)
            let path = UIBezierPath()
            path.moveToPoint(start)
            path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
            path.lineWidth = lineWidth
            return path
            
        }
    
    //handler for pinching gesture
        func scale(gesture: UIPinchGestureRecognizer){
            if gesture.state == .Changed {
                scale *= gesture.scale
                gesture.scale = 1 //reset to get just the delta for every move
            }
        }
    
    override func drawRect(rect: CGRect){
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius,startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke() //actual drawing
        
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        
        //the ?? operator mean that if any value on the left is nil
        //return what on the right side
        let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0 //0.75
        println("smiliness = \(smiliness)")
        
        let smilePath = bezierPathForSmile(smiliness)
        smilePath.stroke()
    }
}
