//
//  SkeletonBones.swift
//  TrackYourMoves
//
//  Created by Stefano  on 05/07/22.
//

import Foundation
import RealityKit


//this struct is used to point up the bones of de body

struct SkeletonBone {
    
    var fromJoint: SkeletonJoint
    var toJoint: SkeletonJoint
    
    var centerPosition:SIMD3<Float>{
        //since the position of a bone is from a joint to another we can assume the center
        //in the middle of the axes between the joints
        
        
        [(fromJoint.position.x + toJoint.position.x)/2 ,(fromJoint.position.y + toJoint.position.y )/2 , (fromJoint.position.z + toJoint.position.z)/2  ]
        
    }
    
    var lenght: Float {
        
        //the lenght of the bone is stated from the distance between two joints
         
        simd_distance(fromJoint.position, toJoint.position)
    }
    
    
}
