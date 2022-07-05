//
//  ArViewContainer.swift
//  TrackYourMoves
//
//  Created by Stefano  on 05/07/22.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit





//this struct let us open the camera as requested from an ARAppView


private var  bodySkeleton: BodySkeleton?
private var bodysSkeletonAnchor = AnchorEntity()

struct ArViewContainer: UIViewRepresentable {
    
    typealias UIViewType = ARView
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.setUpForBodyTracking()
        arView.scene.addAnchor(bodysSkeletonAnchor)
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    //
    }
    
    
    
}

extension ARView: ARSessionDelegate {
    
    func setUpForBodyTracking(){
        let configuration = ARBodyTrackingConfiguration()
        self.session.run(configuration)
        
        self.session.delegate = self
        
    }
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor{
                
                if let skeleton = bodySkeleton {
                    
                    skeleton.update(with: bodyAnchor)
                } else {
                    bodySkeleton = BodySkeleton(for: bodyAnchor)
                    bodysSkeletonAnchor.addChild(bodySkeleton!)
                    
                }
            }
        }
    }
}
