//
//  SLGrid.m
//  SlitherLink
//
//  Created by Rakesh Patole on 9/8/16.
//  Copyright © 2016 Rakesh Patole. All rights reserved.
//

#import "SLGrid.h"
#include <assert.h>
#include "tree234.h"

struct face_score {
    int white_score;
    int black_score;
    unsigned long random;
};

static int generic_sort_cmpfn(void *v1, void *v2, size_t offset)
{
    struct face_score *f1 = v1;
    struct face_score *f2 = v2;
    int r;
    
    r = *(int *)((char *)f2 + offset) - *(int *)((char *)f1 + offset);
    if (r) {
        return r;
    }
    
    if (f1->random < f2->random)
        return -1;
    else if (f1->random > f2->random)
        return 1;

    return f1 - f2;
}

static int white_sort_cmpfn(void *v1, void *v2) {
    return generic_sort_cmpfn(v1, v2, offsetof(struct face_score,white_score));
}

static int black_sort_cmpfn(void *v1, void *v2) {
    return generic_sort_cmpfn(v1, v2, offsetof(struct face_score,black_score));
}

void colorFace(SLGridFace *face, FaceColor color) {
    [face setFaceColor:color];
}

#define FACE_COLOUR(face) \
( (face) == nil ? FACE_COLOR_BLACK : \
[face faceColor] )

int faceNumNeighbours(SLGridFace *fc, FaceColor color ){
    __block int fcScore = 0;
    NSArray *edges = [fc edges];
    [edges enumerateObjectsUsingBlock:^(SLGridFaceEdge *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *faces = [obj faces];
        if( [faces count] == 1 && [[faces firstObject] isEqual:fc] == true ){
            if( FACE_COLOR_BLACK == color ){
                fcScore ++;
            }
        }
        else {
            [faces enumerateObjectsUsingBlock:^(SLGridFace *face, NSUInteger idx, BOOL * _Nonnull stop) {
                if( [face isEqual:fc] == false ){
                    if((FACE_COLOUR(face) == color) ){
                        fcScore ++;
                    }
                }
            }];
        }
    }];
    return fcScore;
}

int faceScoreForColor( SLGridFace *fc, FaceColor color){
    return -faceNumNeighbours(fc, color);
}



bool canColorFace( SLGridFace *test_face, FaceColor colour ){
    __block bool canColor = faceNumNeighbours(test_face, colour) > 0;
    if( canColor == true ){
        __block int transitions = 0;
        NSArray *surrounding_faces = [[[test_face neighbouringFaces] reverseObjectEnumerator] allObjects];
        NSMutableArray *array = [NSMutableArray arrayWithArray:surrounding_faces];
        [array addObject:[array firstObject]];
        surrounding_faces = array;
        __block BOOL previous_face_color = false;
        
        [surrounding_faces enumerateObjectsUsingBlock:^(SLGridFace *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            bool current_color = ([obj isEqual:[NSNull null]] ? FACE_COLOR_BLACK : [obj faceColor]) == colour;
            if( idx == 0 ){
                previous_face_color = current_color;
            }
            else {
                if( previous_face_color != current_color) {
                    transitions += 1;
                    previous_face_color = current_color;
                    *stop = ( transitions > 2 );
                }
            }
        }];
        
        canColor = (transitions == 2) ? TRUE : FALSE;
    }
    
    return canColor;
}

void generate_loop(SLGrid *grid) {
    NSArray *faces = [grid faces];
    int numberOfFaces = (int)[faces count];
    
    NSUInteger randomFace = arc4random() % numberOfFaces;
    SLGridFace *face = faces[randomFace];
    colorFace( face, FACE_COLOR_WHITE);
    
    tree234 *darkColoredFaces = newtree234(black_sort_cmpfn);
    tree234 *lightColoredFaces = newtree234(white_sort_cmpfn);
    
    struct face_score *face_scores = snewn( numberOfFaces, struct face_score);
    for (int i = 0; i < numberOfFaces; i++) {
        face_scores[i].random = arc4random() % 31;
        face_scores[i].black_score = face_scores[i].white_score = 0;
    }
    
    [faces enumerateObjectsUsingBlock:^(SLGridFace *fc, NSUInteger idx, BOOL * _Nonnull stop) {
        if( [fc faceColor] == FACE_COLOR_GREY ){
            struct face_score *fs = face_scores + idx;
            if( canColorFace(fc, FACE_COLOR_BLACK)){
                int score = faceScoreForColor( fc, FACE_COLOR_BLACK);
                fs->black_score = score;
                add234(darkColoredFaces, fs);
            }
            if ( canColorFace(fc, FACE_COLOR_WHITE)){
                int score = faceScoreForColor( fc, FACE_COLOR_WHITE);
                fs->white_score = score;
                add234(lightColoredFaces, fs);
            }
        }
    }];
    
    while (true ) {
        int c_lightable = count234(lightColoredFaces);
        int c_darkable = count234(darkColoredFaces);
        if (c_lightable == 0 && c_darkable == 0) {
            break;
        }
        
        FaceColor color = arc4random() % 2 ? FACE_COLOR_WHITE : FACE_COLOR_BLACK;
        tree234 *faceToPick = (color == FACE_COLOR_BLACK) ? darkColoredFaces : lightColoredFaces;
        if( count234(faceToPick) > 0 ){
            struct face_score *fs = index234(faceToPick, 0);
            int index = fs - face_scores;
            SLGridFace *face = faces[index];
            [face setFaceColor:color];
            
            del234( darkColoredFaces, fs);
            del234( lightColoredFaces, fs);
            
            NSArray *uniquFaces = [face neighbouringFaces];
            [uniquFaces enumerateObjectsUsingBlock:^(SLGridFace *fc, NSUInteger idx, BOOL * _Nonnull stop) {
                if( [fc isEqual:[NSNull null]] == false && [fc isEqual:face] == false && [fc faceColor] == FACE_COLOR_GREY ){
                    struct face_score *_fs = face_scores + [faces indexOfObject:fc];
                    del234(lightColoredFaces, _fs);
                    if ( canColorFace(fc, FACE_COLOR_WHITE)){
                        int score = faceScoreForColor( fc, FACE_COLOR_WHITE);
                        _fs->white_score = score;
                        add234(lightColoredFaces, _fs);
                    }
                    
                    del234(darkColoredFaces, _fs);
                    if( canColorFace(fc, FACE_COLOR_BLACK)){
                        int score = faceScoreForColor( fc, FACE_COLOR_BLACK);
                        _fs->black_score = score;
                        add234(darkColoredFaces, _fs);
                    }
                }
            }];
        }
    }
    
    
    freetree234(lightColoredFaces);
    freetree234(darkColoredFaces);
    sfree(face_scores);
    
    NSMutableArray *array = [NSMutableArray array];
    for( int i = 0; i<numberOfFaces; i++){
        [array addObject:[NSNumber numberWithInt:i]];
    }
    
    for( int index = (int)numberOfFaces ; index-- > 1; ){
        int otherIndex = arc4random()%(index+1);
        id firstObject = array[index];
        [array replaceObjectAtIndex:index withObject:[array objectAtIndex:otherIndex]];
        [array replaceObjectAtIndex:otherIndex withObject:firstObject];
    }
    
    bool do_random_pass = false;
    while (true) {
        int flipped = false;
        for (int i = 0; i < numberOfFaces; ++i) {
            NSNumber *index = array[i];
            SLGridFace *fc = faces[index.intValue];
            FaceColor opp = ([fc faceColor] == FACE_COLOR_WHITE) ? FACE_COLOR_BLACK : FACE_COLOR_WHITE;
            if (canColorFace( fc, opp) ){
                if (do_random_pass) {
                    if (!(arc4random() % 11))
                        [fc setFaceColor:opp];
                } else {
                    if ( faceNumNeighbours( fc, opp) == 1) {
                        [fc setFaceColor:opp];
                        flipped = true;
                    }
                }
            }
        }
        
        if (do_random_pass) break;
        if (!flipped) do_random_pass = true;
    }
}

#pragma mark - Face Edge
@implementation SLGridFaceEdge

+ (SLGridFaceEdge *) gridEdge {
    return [[SLGridFaceEdge alloc] init];
}

- (NSArray *) faces {
    NSArray *corner1Faces = [self.faceCorner1 allFaces];
    NSArray *corner2Faces = [self.faceCorner2 allFaces];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SLGridFace *face, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [corner2Faces containsObject:face];
    }];

    return [corner1Faces filteredArrayUsingPredicate:predicate];
}

- (BOOL) highLightEdge {
    NSArray *faces = [self faces];
    BOOL canHighLight = false;
    if( faces.count == 1 ){
        canHighLight = [faces[0] faceColor] == FACE_COLOR_WHITE;
    }
    else {
        NSSet *set = [NSSet setWithArray:[faces valueForKeyPath:@"faceColor"]];
        canHighLight = ([faces count] == [set count]);
    }
    return canHighLight;
}

- (SLGridFace *) face1 {
    return [[self faces] firstObject];
}
- (SLGridFace *) face2 {
    return [[self faces] lastObject];
}

@end

#pragma mark - Face Corner
@interface SLGridFaceCorner() {
    NSArray *allFaces;
}

- (void) addEdge:(SLGridFaceEdge *)edge;
- (void) addFace:(SLGridFace *)face;

@end

@implementation SLGridFaceCorner

@synthesize faces = _faces;

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
        for( int  i=0; i <4; i ++){
            [_faces addObject:[NSNull null]];
        }
    }
    return _faces;
}

- (NSArray *) allFaces {
    if( allFaces == nil ){
        NSMutableSet *uniqueFaces = [NSMutableSet setWithArray:[self faces]];
        [uniqueFaces removeObject:[NSNull null]];
        allFaces = [uniqueFaces allObjects];
    }
    return allFaces;
}

- (void) addEdge:(SLGridFaceEdge *)edge {
    [[self edges] addObject:edge];
}


- (void) addFace:(SLGridFace *)face {
    [[self faces] addObject:face];
    allFaces = nil;
}

- (void) addFace:(SLGridFace *)face atIndex:(NSUInteger)index {
    [[self faces] removeObjectAtIndex:index];
    [[self faces] insertObject:face atIndex:index];
    allFaces = nil;
}

- (SLGridFace *) faceAtIndex:(NSInteger)index {
    id face = [[self faces] objectAtIndex:index];
    if( [face isEqual:[NSNull null]] ){
        face = nil;
    }
    return face;
}

@end

#pragma mark - Grid Face
@interface SLGridFace() {
    NSArray *neighbouringFaces;
}

@end

@implementation SLGridFace

@synthesize corners = _corners;

+ (SLGridFace *) gridFace {
    return [[SLGridFace alloc] init];
}

- (id) init {
    self = [super init];
    if( self != nil ){
        self.faceColor = FACE_COLOR_GREY;
    }
    return self;
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (void) setCorners:(NSArray *)corners {
    _corners = corners;
}

- (NSArray *) neighbouringFaces {
    if( neighbouringFaces == nil ){
        SLGridFace *test_face = self;
        NSMutableArray *unique_faces = [NSMutableArray array];
        NSArray *test_face_corners = [test_face corners];
        int corner_idx = 0;
        int face_idx = 0;
        SLGridFace *current_face = [test_face_corners[corner_idx] faces][face_idx];
        SLGridFace *starting_face = nil;
        SLGridFaceCorner *starting_corner = nil;
        if( [current_face isEqual:test_face] == true ){
            face_idx ++;
            current_face = [test_face_corners[corner_idx] faces][face_idx];
        }
        
        while (true) {
            while( true ){
                face_idx += 1;
                face_idx = face_idx % [test_face_corners[corner_idx] faces].count;
                
                SLGridFace *face = [test_face_corners[corner_idx] faces][face_idx];
                if([face isEqual:test_face] == true){
                    corner_idx += 1;
                    corner_idx = corner_idx % [[test_face corners] count];
                    for( face_idx = 0;
                        face_idx < [test_face_corners[corner_idx] faces].count;
                        face_idx ++ ){
                        SLGridFace *face = [test_face_corners[corner_idx] faces][face_idx];
                        if( [current_face isEqual:face] == true){
                            break;
                        }
                    }
                    
                    NSAssert( face_idx != [test_face_corners[corner_idx] faces].count, @"How did we reach here");
                }
                else {
                    break;
                }
            }
            
            current_face = [test_face_corners[corner_idx] faces][face_idx];
            if( [unique_faces containsObject:current_face] == false ){
                [unique_faces addObject:current_face];
            }
            
            if( starting_face == nil ){
                starting_face = current_face;
                starting_corner = test_face_corners[corner_idx];
            }
            else {
                if( [current_face isEqual:starting_face] &&
                   [test_face_corners[corner_idx] isEqual:starting_corner ]) {
                    break;
                }
            }
        }
        
        neighbouringFaces = unique_faces;
    }
    return neighbouringFaces;
}

@end



//        do {
//            corner_idx += 1;
//            corner_idx = corner_idx % 4;
//        } while (corner_idx != 0);

//        for ( int corner_idx = 0; corner_idx < [[self corners] count]; corner_idx += 1) {
//            SLGridFaceCorner *corner = test_face_corners[corner_idx];
//            NSArray *corner_faces = [corner faces];
//            NSInteger index = [corner_faces indexOfObject:test_face];
//            index += 1;
//            index = index % [corner_faces count];
//
//            while ( corner_faces[index] != test_face) {
//                SLGridFace *face = [corner faceAtIndex:index];
//                if( face != nil && [face isEqual:test_face] == false && [unique_faces containsObject:face] == false ){
//                    [unique_faces addObject:face];
//                }
//                index += 1;
//                index = index % [corner_faces count];
//            }
//        }

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
                [corner0 addFace:face atIndex:2];
                [corner1 addFace:face atIndex:3];
                [corner2 addFace:face atIndex:0];
                [corner3 addFace:face atIndex:1];
                
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
    generate_loop(grid);
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
