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
    NSArray *faces = [[self grid] faces];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat lineLen = 0.0f;
    CGFloat margin = 40.0f;
    if( width > height ){
        lineLen = (height - margin) / [self.grid size].height;
    }
    else {
        lineLen = (width - margin) / [self.grid size].width;
    }
    CGFloat startX = (width - lineLen * self.grid.size.width) / 2.0f;
    CGFloat startY = (height - lineLen * self.grid.size.height) / 2.0f;
    
    
    [faces enumerateObjectsUsingBlock:^(SLGridFace *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint origin = CGPointMake((obj.position.x * lineLen) + startX,
                                     (obj.position.y * lineLen) + startY);
        CGSize size = CGSizeMake( lineLen, lineLen);
        CGRect rect;
        rect.origin = origin;
        rect.size = size;
        UIColor *faceColor = [UIColor redColor];
        if( [obj faceColor] == FACE_COLOR_WHITE ){
            faceColor = [UIColor darkGrayColor];
        }
        else if ([obj faceColor] == FACE_COLOR_BLACK ){
            faceColor = [UIColor lightGrayColor];
        }
        
        [self drawRect:rect
             inContect:context
                 color:faceColor];
    }];
    
    
    [edges enumerateObjectsUsingBlock:^(SLGridFaceEdge *edge, NSUInteger idx, BOOL * _Nonnull stop) {
        SLGridFaceCorner *corner1 = [edge faceCorner1];
        SLGridFaceCorner *corner2 = [edge faceCorner2];
        CGPoint p1 = CGPointMake((corner1.position.x * lineLen) + startX,
                                 (corner1.position.y * lineLen) + startY);
        CGPoint p2 = CGPointMake((corner2.position.x * lineLen) + startX,
                                 (corner2.position.y * lineLen) + startY);
        [self drawLineWithP1:p1
                       andP2:p2
                   inContext:context
                       color:([edge highLightEdge])? [UIColor blackColor] : [UIColor darkGrayColor]];
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

- (void) drawRect:(CGRect)rect inContect:(CGContextRef)context color:(UIColor *)color {
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
}

@end
