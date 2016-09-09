//
//  SLGrid.m
//  SlitherLink
//
//  Created by Rakesh Patole on 9/8/16.
//  Copyright © 2016 Rakesh Patole. All rights reserved.
//

#import "SLGrid.h"

#pragma mark - Face Edge
@implementation SLGridFaceEdge

+ (SLGridFaceEdge *) gridEdge {
    return [[SLGridFaceEdge alloc] init];
}

- (NSArray *) faces {
    return nil;
}

@end

#pragma mark - Face Corner
@interface SLGridFaceCorner()

- (void) addEdge:(SLGridFaceEdge *)edge;
- (void) addFace:(SLGridFace *)face;

@end

@implementation SLGridFaceCorner

+ (SLGridFaceCorner *) gridFaceCorner {
    return [[SLGridFaceCorner alloc] init];
}

- (NSMutableArray *) edges {
    if( _edges == nil ){
        _edges = [NSMutableArray array];
    }
    return _edges;
}

- (NSMutableArray *) faces {
    if( _faces == nil ){
        _faces = [NSMutableArray array];
    }
    return _faces;
}

- (void) addEdge:(SLGridFaceEdge *)edge {
    [[self edges] addObject:edge];
}


- (void) addFace:(SLGridFace *)face {
    [[self faces] addObject:face];
}

@end

#pragma mark - Grid Face
@implementation SLGridFace

@synthesize corners = _corners;

+ (SLGridFace *) gridFace {
    return [[SLGridFace alloc] init];
}

- (void) setCorners:(NSArray *)corners {
    _corners = corners;
}

@end

#pragma mark - Grid
@interface SLGrid() {
    
}

@end


@implementation SLGrid

+ (SLGrid *) gridWithSize:(CGSize)gridSize {
    SLGrid *grid = [[SLGrid alloc] init];
    [grid setSize:gridSize];
    if( CGSizeEqualToSize( CGSizeZero, gridSize) == false ){
        for ( NSUInteger rowIdx = 0; rowIdx < gridSize.height; rowIdx ++ ) {
            for ( NSUInteger colIdx = 0; colIdx < gridSize.width; colIdx ++) {
                SLGridFace *face = [SLGridFace gridFace];
                [face setPosition:CGPointMake(rowIdx, colIdx)];
                [[grid faces] addObject:face];
                
                SLGridFaceCorner *corner0 = [self gridFaceCornerAtPosition:CGPointMake(rowIdx, colIdx)
                                                                    inGrid:grid];
                SLGridFaceCorner *corner1 = [self gridFaceCornerAtPosition:CGPointMake(rowIdx, colIdx + 1)
                                                                    inGrid:grid];
                SLGridFaceCorner *corner2 = [self gridFaceCornerAtPosition:CGPointMake(rowIdx + 1, colIdx + 1)
                                                                    inGrid:grid];
                SLGridFaceCorner *corner3 = [self gridFaceCornerAtPosition:CGPointMake(rowIdx + 1, colIdx)
                                                                    inGrid:grid];
                
                [face setCorners:@[corner0,corner1,corner2,corner3]];
                
                SLGridFaceEdge *edge0 = [self gridEdgeForCorner:corner0 and:corner1
                                                         inGrid:grid];
                SLGridFaceEdge *edge1 = [self gridEdgeForCorner:corner1 and:corner2
                                                         inGrid:grid];
                SLGridFaceEdge *edge2 = [self gridEdgeForCorner:corner2 and:corner3
                                                         inGrid:grid];
                SLGridFaceEdge *edge3 = [self gridEdgeForCorner:corner3 and:corner0
                                                         inGrid:grid];
                
                [face setEdges:@[edge0,edge1,edge2,edge3]];
            }
        }
    }
    return grid;
}

- (NSMutableArray *) faces {
    if( _faces == nil ){
        _faces = [NSMutableArray array];
    }
    return _faces;
}

- (NSMutableArray *) edges {
    if( _edges == nil ){
        _edges = [NSMutableArray array];
    }
    return _edges;
}

- (NSMutableArray *) faceCorners {
    if( _faceCorners == nil ){
        _faceCorners = [NSMutableArray array];
    }
    return _faceCorners;
}

- (SLGridFaceCorner *) faceCornerWithPosition:(CGPoint)position {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SLGridFaceCorner *corner,
                                                                   NSDictionary<NSString *,id> * _Nullable bindings) {
        return CGPointEqualToPoint( [corner position], position);
    }];
    
    NSArray *filteredArray = [[self faceCorners] filteredArrayUsingPredicate:predicate];
    SLGridFaceCorner *corner = [filteredArray firstObject];
    return corner;
}

- (SLGridFaceEdge *) edgeWithCorner:(SLGridFaceCorner *)corner1 and:(SLGridFaceCorner *)corner2 {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SLGridFaceEdge *edge,
                                                                   NSDictionary<NSString *,id> * _Nullable bindings) {
        SLGridFaceCorner *cr1 = edge.faceCorner1;
        SLGridFaceCorner *cr2 = edge.faceCorner2;
        return (([cr1 isEqual:corner1] || [cr1 isEqual:corner2]) && ([cr2 isEqual:corner1] || [cr2 isEqual:corner2]));
    }];
    
    NSArray *filteredArray = [[self edges] filteredArrayUsingPredicate:predicate];
    SLGridFaceEdge *edge = [filteredArray firstObject];
    return edge;
}

+ (SLGridFaceEdge *) gridEdgeForCorner:(SLGridFaceCorner *)corner1
                                   and:(SLGridFaceCorner *)corner2
                                inGrid:(SLGrid *)grid {
    
    SLGridFaceEdge *edge = [grid edgeWithCorner:corner1
                                            and:corner2];
    if( edge == nil ){
        edge = [SLGridFaceEdge gridEdge];
        [edge setFaceCorner1:corner1];
        [edge setFaceCorner2:corner2];
        [[grid edges] addObject:edge];
        [corner1 addEdge:edge];
        [corner2 addEdge:edge];
    }
    
    return edge;
}

+ (SLGridFaceCorner *) gridFaceCornerAtPosition:(CGPoint)position
                                         inGrid:(SLGrid *)grid {
    SLGridFaceCorner *corner = [grid faceCornerWithPosition:position];
    if( corner == nil ){
        corner = [SLGridFaceCorner gridFaceCorner];
        [corner setPosition:position];
        [[grid faceCorners] addObject:corner];
    }
    return corner;
}

@end