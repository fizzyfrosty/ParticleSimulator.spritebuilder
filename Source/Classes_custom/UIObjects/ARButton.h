//
//  ARButton.h
//  Janus
//
//  Created by Simon Chen on 8/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@class ARButton;

@protocol ARButtonDelegate <NSObject>

@optional
- (void)arbuttonDidGetPressed:(ARButton *)button;

@end

@interface ARButton : CCNode


- (instancetype)initWithDefaultImageNamed:(NSString *)defaultImageName highlightedImageNamed:(NSString *)highlightedImageName;


@property (nonatomic, strong, setter=setHighlightedSprite:) CCSprite *highlightedSprite;
@property (nonatomic, strong, setter=setDefaultSprite:) CCSprite *defaultSprite;
@property (nonatomic, assign) CGRect hitboxRect;
@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, weak) id<ARButtonDelegate> delegate;


// Starting Methods
@property (nonatomic, assign) CGPoint touchBeganPosition_local;
@property (nonatomic, assign) CGPoint touchMovedPosition_local;
@property (nonatomic, assign) CGPoint touchEndedPosition_local;

@end
