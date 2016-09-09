//
//  SLGrid.h
//  SlitherLink
//
//  Created by Rakesh Patole on 9/8/16.
//  Copyright © 2016 Rakesh Patole. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLGridFaceCorner : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) NSMutableArray *edges;
@property (nonatomic) NSMutableArray *faces;

+ (SLGridFaceCorner *) gridFaceCorner;

@end

@interface SLGridFaceEdge : NSObject

+ (SLGridFaceEdge *) gridEdge;

@property (nonatomic, weak) SLGridFaceCorner * faceCorner1;
@property (nonatomic, weak) SLGridFaceCorner * faceCorner2;

- (NSArray *) faces;

@end

@interface SLGridFace : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic, strong) NSArray *corners;
@property (nonatomic, strong) NSArray *edges;

+ (SLGridFace *) gridFace;

@end

@interface SLGrid : NSObject {
    
}
@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSMutableArray *faces;
@property (nonatomic, strong) NSMutableArray *edges;
@property (nonatomic, strong) NSMutableArray *faceCorners;

+ (SLGrid *) gridWithSize:(CGSize)size;

@end