//
//  BodySkeleton.swift
//  TrackYourMoves
//
//  Created by Stefano  on 05/07/22.
//

import Foundation
import RealityKit
import ARKit

//this class contains all the components (entity in ARkit) we need to visualize

class BodySkeleton:Entity {
    //this is an entities' dictionary
    
    //this will keep track of bones and joints in our ARkit scene
    
    var joints:[String : Entity] = [:]
    var bones:[String : Entity] = [:]
    
    required init(for bodyAnchor:ARBodyAnchor){
        
        super.init()
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            var jointRadius: Float = 0.05
            var jointColor: UIColor = .green
            
            
            switch jointName {
                
            case "neck_1_joint", "neck_2_joint", "neck_3_joint", "neck_4_joint", "head_joint",
                "left shoulder_1_joint","right_shoulder 1 joint":
                jointRadius *= 0.5
                
            case "jaw_joint", "chin joint", "left_eye_joint", "left_eyeLowerLid_joint", "left_eyeUpperLid_joint",
                "left_eyeball_joint", "nose_joint", "right_eye_joint", "right_eyeLowerLid_joint", "right_eyeUpperlid_joint", "right_eyeball_joint":
                jointRadius *= 0.2
                jointColor = .yellow
                
            case _ where jointName.hasPrefix("spine_"):
                jointRadius *= 0.75
                
            case "left_hand_joint", "right_hand_joint":
                jointRadius *= 1
                jointColor = .green
                
            case _ where jointName.hasPrefix("left_hand") || jointName.hasPrefix("right_hand"):
                jointRadius *= 0.25
                jointColor = .yellow
                
            case _ where jointName.hasPrefix("left_toes") || jointName.hasPrefix("right_toes"):
                jointRadius *= 0.5
                jointColor = .yellow default:
                jointRadius = 0.05
                jointColor = .green
                
                
                
            }
            
            let jointEntity = createJoint(radius: jointRadius, color: jointColor)
            
            joints[jointName] = jointEntity
            
            self.addChild(jointEntity)
        }
        
        for bone in Bones.allCases {
            
            guard let skeletonBone = createSkeltonBody(bone: bone, bodyAnchor: bodyAnchor)
                    //createSkeltonBody(bone: bone, bodyAnchor: bodyAnchor)
            else {continue}
            
            let boneEntity = createBoneFromEntity(for: skeletonBone)
            bones[bone.name] = boneEntity
            self.addChild(boneEntity)
        }
        
    }
    
    //in case the method isn't used this error will be shown
    required init() {
        fatalError("init() has not been implemented")
    }
    
    
    func update(with bodyAnchor: ARBodyAnchor) {
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames{
            if let jointEntity = joints[jointName],
               let jointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName (rawValue:jointName)){
                
                let jointEntityoffsetFromRoot = simd_make_float3(jointEntityTransform.columns.3)
                jointEntity.position = jointEntityoffsetFromRoot + rootPosition
                jointEntity.orientation = Transform(matrix:jointEntityTransform).rotation
            }
            
        }
        
        for bone in Bones.allCases{
            
            let boneName = bone.name
            
            guard let entity = bones[boneName],
                  let skeletonBone = createSkeltonBody(bone: bone, bodyAnchor: bodyAnchor)
            else {continue}
            
            //setting orientation in bone
            entity.position = skeletonBone.centerPosition
            entity.look(at: skeletonBone.toJoint.position, from: skeletonBone.centerPosition, relativeTo: nil)
            
        }
        
    }
    
    
    //this methods create the entities
    private func createJoint(radius:Float, color: UIColor) -> (Entity){
        
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: color, roughness: 0.8, isMetallic: true) //try also with false on isMetallic
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        //this way we can return an entity for each joints in the body
        return entity
    }
    
    //the bone is optional since may not exist
    private func createSkeltonBody(bone:Bones, bodyAnchor: ARBodyAnchor) -> SkeletonBone? {
        guard let fromJointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName (rawValue:
                                                                                                            bone.jointFromName)), let toJointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName (rawValue:
                                                                                                                                                                                                                                bone.jointToName)) else { return nil }
        
        
        
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        //this is in relation to the root joint
        let jointFromEntityoffsetFromRoot = simd_make_float3(fromJointEntityTransform.columns.3)
        
        
        let jointFromentityPosition = jointFromEntityoffsetFromRoot + rootPosition
        let jointToEntityoffsetFromRoot = simd_make_float3(toJointEntityTransform.columns.3)
        let jointToEntityPosition = jointToEntityoffsetFromRoot + rootPosition
        let fromJoint = SkeletonJoint(name: bone.jointFromName, position: jointFromentityPosition)
        let toJoint = SkeletonJoint(name: bone.jointToName, position: jointToEntityPosition)
        return SkeletonBone(fromJoint: fromJoint, toJoint: toJoint)
    }
    
    private func createBoneFromEntity(for skeletonBone: SkeletonBone, diameter: Float = 0.04, color: UIColor = .white) -> Entity {
        
        let mesh = MeshResource.generateBox(size: [diameter, diameter, skeletonBone.lenght], cornerRadius:diameter/2)
        let material = SimpleMaterial(color: color, roughness: 0.5, isMetallic: true)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }
}
