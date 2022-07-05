//
//  SkeletonJoint.swift
//  TrackYourMoves
//
//  Created by Stefano  on 05/07/22.
//

import Foundation

//this  structures contains the Joints of body structure


struct SkeletonJoint {
    
    let name:String
    
    //Simd3 is a  vector of three scalar values really useful for 3d positions
    
    var position:SIMD3<Float>
    
    
}
