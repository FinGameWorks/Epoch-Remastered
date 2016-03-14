//
//  JZ_Player.m
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/11.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZ_Player.h"

@implementation JZ_Player
@synthesize ShipSceneName;


- (void)LogicUpdate
{
    //NSLog(@"LogicUpdate:%@",NSStringFromClass([self class]));
}
- (void)LogicFixedUpdate
{
    //NSLog(@"LogicFixedUpdate:%@",NSStringFromClass([self class]));
}


- (void)initShip
{
    SCNNode *ShipNode = [[SCNScene sceneNamed:ShipSceneName inDirectory:@"art.scnassets" options:nil].rootNode clone];
    [self addChildNode:ShipNode];
    ShipNode.position = SCNVector3Make(0.0f, 0.0f, 0.0f);
    
    self.physicsBody = [SCNPhysicsBody dynamicBody];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.damping = 0.1f;
    self.physicsBody.angularDamping = 0.4f;
    self.physicsBody.mass = 0.5f;
    //self.physicsBody.rollingFriction = 0.1f;
    
//    self.physicsBody.physicsShape = [SCNPhysicsShape shapeWithNode:self options:@{SCNPhysicsShapeTypeKey:SCNPhysicsShapeTypeBoundingBox,
//                                                                                  SCNPhysicsShapeKeepAsCompoundKey:@YES}];
}

//+(instancetype)nodeWithShipSceneName:(NSString *)name
//{
//    //SCNNode *ShipNode = [[SCNScene sceneNamed:name inDirectory:@"art.scnassets" options:nil].rootNode clone];
//    JZ_Player *ShipNode = [[SCNScene sceneNamed:name inDirectory:@"art.scnassets" options:nil].rootNode clone];
//    return ShipNode;
//}

@end
