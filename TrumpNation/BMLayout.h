//
//  BMLayout.h
//  BroadcastMe
//
//  Created by Mihaita Babici on 11/2/16.
//  Copyright © 2016 Agilio. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface BMLayout : NSObject

/// ----------------------------------------
/// @name Public methods
/// ----------------------------------------

/**
 Activates constraints that are binding the given subview to the margins of the parent.
 Use this to autolayout views that are the same size as the parent and will resize together.

 @param subview The subview.
 @param parent  The parent view.
 */
+ (void)bindSubview:(UIView *)subview toParent:(UIView *)parent;

/**
 Activates constraints that are centering the given subview inside the given parent view.
 Use this to center both horizontally and vertically the given view.

 @param subview The subview.
 @param parent  The parent view.
 */
+ (void)centerSubview:(UIView *)subview inParent:(UIView *)parent;

+ (void)centerSubview:(UIView *)subview horizontallyInParent:(UIView *)parent;

+ (void)centerSubview:(UIView *)subview verticallyInParent:(UIView *)parent;

+ (void)lockWidth:(CGFloat)width forView:(UIView *)view;

+ (void)lockMinWidth:(CGFloat)width forView:(UIView *)view;

+ (void)lockMaxWidth:(CGFloat)width forView:(UIView *)view;

+ (void)lockHeight:(CGFloat)height forView:(UIView *)view;

+ (void)lockMinHeight:(CGFloat)height forView:(UIView *)view;

+ (void)lockMaxHeight:(CGFloat)height forView:(UIView *)view;

+ (void)lockWidth:(CGFloat)width andHeight:(CGFloat)height forView:(UIView *)view;

@end
