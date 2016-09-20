//
//  SLGrid.h
//  SlitherLink
//
//  Created by Rakesh Patole on 9/8/16.
//  Copyright © 2016 Rakesh Patole. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SLGridFace;

@interface SLGridFaceCorner : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) NSMutableArray *edges;
@property (nonatomic) NSMutableArray *faces; // cyclic retain count

+ (SLGridFaceCorner *) gridFaceCorner;
- (void) addFace:(SLGridFace *)face atIndex:(NSUInteger)index;
- (SLGridFace *) faceAtIndex:(NSInteger)index;
- (NSUInteger) faceCount;
- (NSArray *) allFaces;

@end

@interface SLGridFaceEdge : NSObject

+ (SLGridFaceEdge *) gridEdge;

@property (nonatomic, weak) SLGridFaceCorner * faceCorner1;
@property (nonatomic, weak) SLGridFaceCorner * faceCorner2;

- (NSArray *) faces;
- (BOOL) highLightEdge;
- (SLGridFace *) face1;
- (SLGridFace *) face2;

@end

typedef enum _FaceColor { FACE_COLOR_WHITE, FACE_COLOR_GREY, FACE_COLOR_BLACK} FaceColor;

@interface SLGridFace : NSObject <NSCopying>

@property (nonatomic) CGPoint position;
@property (nonatomic, strong) NSArray *corners; //cyclic retain count
@property (nonatomic, strong) NSArray *edges;
@property (nonatomic) FaceColor faceColor;

+ (SLGridFace *) gridFace;
- (NSArray *) neighbouringFaces;

@end

@interface SLGrid : NSObject {
    
}
@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSMutableArray *faces;
@property (nonatomic, strong) NSMutableArray *edges;
@property (nonatomic, strong) NSMutableArray *faceCorners;

+ (SLGrid *) gridWithSize:(CGSize)size;

@end