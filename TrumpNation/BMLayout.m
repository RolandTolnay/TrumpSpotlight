//
//  BMLayout.m
//  BroadcastMe
//
//  Created by Mihaita Babici on 11/2/16.
//  Copyright © 2016 Agilio. All rights reserved.
//

#import "BMLayout.h"

@implementation BMLayout

#pragma mark - Lifecycle

#pragma mark - Properties

#pragma mark - Public methods

+ (void)bindSubview:(UIView *)subview toParent:(UIView *)parent {
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:subview
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:parent
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f
                                                                constant:0.0f];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:subview
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:parent
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0f
                                                                 constant:0.0f];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:subview
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parent
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0f
                                                            constant:0.0f];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:subview
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:parent
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:0.0f];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[leading, trailing, top, bottom]];
}

+ (void)centerSubview:(UIView *)subview inParent:(UIView *)parent {
    [self centerSubview:subview horizontallyInParent:parent];
    [self centerSubview:subview verticallyInParent:parent];
}

+ (void)centerSubview:(UIView *)subview horizontallyInParent:(UIView *)parent {
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:subview
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:parent
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0f
                                                                constant:0.0f];
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[centerX]];
}

+ (void)centerSubview:(UIView *)subview verticallyInParent:(UIView *)parent {
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:subview
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:parent
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0f
                                                                constant:0.0f];
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[centerY]];
}

+ (void)lockWidth:(CGFloat)width forView:(UIView *)view {
    NSLayoutConstraint *fixedWidth = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:width];
    
    [NSLayoutConstraint activateConstraints:@[fixedWidth]];
}

+ (void)lockMinWidth:(CGFloat)width forView:(UIView *)view {
    NSLayoutConstraint *fixedWidth = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:width];
    
    [NSLayoutConstraint activateConstraints:@[fixedWidth]];
}

+ (void)lockMaxWidth:(CGFloat)width forView:(UIView *)view {
    NSLayoutConstraint *fixedWidth = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:width];
    
    [NSLayoutConstraint activateConstraints:@[fixedWidth]];
}

+ (void)lockHeight:(CGFloat)height forView:(UIView *)view {
    NSLayoutConstraint *fixedHeight = [NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:height];
    
    [NSLayoutConstraint activateConstraints:@[fixedHeight]];
}

+ (void)lockMinHeight:(CGFloat)height forView:(UIView *)view {
    NSLayoutConstraint *fixedHeight = [NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:height];
    
    [NSLayoutConstraint activateConstraints:@[fixedHeight]];
}

+ (void)lockMaxHeight:(CGFloat)height forView:(UIView *)view {
    NSLayoutConstraint *fixedHeight = [NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:height];
    
    [NSLayoutConstraint activateConstraints:@[fixedHeight]];
}

+ (void)lockWidth:(CGFloat)width andHeight:(CGFloat)height forView:(UIView *)view {
    [self lockWidth:width forView:view];
    [self lockHeight:height forView:view];
}

#pragma mark - Private methods

@end
