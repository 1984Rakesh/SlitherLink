//
//  SLGameView.m
//  SlitherLink
//
//  Created by Rakesh Patole on 9/12/16.
//  Copyright © 2016 Rakesh Patole. All rights reserved.
//

#import "SLGameView.h"

@implementation SLGameView


- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSArray *edges = [[self grid] edges];
    CGFloat lineLen = 30.0f;
    [edges enumerateObjectsUsingBlock:^(SLGridFaceEdge *edge, NSUInteger idx, BOOL * _Nonnull stop) {
        SLGridFaceCorner *corner1 = [edge faceCorner1];
        SLGridFaceCorner *corner2 = [edge faceCorner2];
        CGPoint p1 = CGPointMake( corner1.position.x * lineLen, corner1.position.y * lineLen);
        CGPoint p2 = CGPointMake( corner2.position.x * lineLen, corner2.position.y * lineLen);
        [self drawLineWithP1:p1
                       andP2:p2
                   inContext:context
                       color:[UIColor blackColor]];
    }];
    
    
}

- (void) drawLineWithP1:(CGPoint)p1 andP2:(CGPoint)p2 inContext:(CGContextRef)context color:(UIColor *)color {
    CGContextSetStrokeColorWithColor( context, color.CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    CGContextStrokePath(context);
}

- (void) drawText:(NSString *)text inContext:(CGContextRef *)context color:(UIColor *)color{
    
}

@end
