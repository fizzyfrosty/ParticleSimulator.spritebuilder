//
//  ARButton.m
//  Janus
//
//  Created by Simon Chen on 8/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ARButton.h"

@implementation ARButton

@synthesize enabled = _enabled;

- (instancetype)initWithDefaultImageNamed:(NSString *)defaultImageName highlightedImageNamed:(NSString *)highlightedImageName
{
    self = [super init];
    if (!self) return nil;
    
    self.userInteractionEnabled = YES;
    [self initializeARButtonWithDefaultImageNamed:defaultImageName highlightedImageNamed:highlightedImageName];
    
    return self;
}

- (void)initializeARButtonWithDefaultImageNamed:(NSString *)defaultImageName highlightedImageNamed:(NSString *)highlightedImageName
{
    @try {
        // Create Sprites
        _defaultSprite = [CCSprite spriteWithImageNamed:defaultImageName];
        _highlightedSprite = [CCSprite spriteWithImageNamed:highlightedImageName];
        
        // Content Size
        self.contentSize = self.defaultSprite.contentSize;
        
        // Anchor Point
        self.anchorPoint = ccp(0.5f, 0.5f);
        
        
        [self addChild:self.defaultSprite];
        [self addChild:self.highlightedSprite];
        
        // Positions centered in object
        self.defaultSprite.position = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
        self.highlightedSprite.position = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
        
        // Hitbox Rect
        self.hitboxRect = CGRectMake(_defaultSprite.position.x - _defaultSprite.contentSize.width/2.0f, _defaultSprite.position.y - _defaultSprite.contentSize.height/2.0f, _defaultSprite.contentSize.width, _defaultSprite.contentSize.height);
        
        [self showDefaultSprite];
        
        _enabled = TRUE;
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)showDefaultSprite
{
    @try {
        self.defaultSprite.visible = TRUE;
        self.highlightedSprite.visible = FALSE;
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)showHighlightedSprite
{
    @try {
        self.highlightedSprite.visible = TRUE;
        self.defaultSprite.visible = FALSE;
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

#pragma mark - Custom Setters

- (void)setHighlightedSprite:(CCSprite *)highlightedSprite
{
    _highlightedSprite = highlightedSprite;
    
    // Set position
    _highlightedSprite.position = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
}

- (void)setDefaultSprite:(CCSprite *)defaultSprite
{
    _defaultSprite = defaultSprite;
    
    // Set position
    self.contentSize = _defaultSprite.contentSize;
    
    _defaultSprite.position = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
    _highlightedSprite.position = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
    _hitboxRect = CGRectMake(_defaultSprite.position.x - _defaultSprite.contentSize.width/2.0f, _defaultSprite.position.y - _defaultSprite.contentSize.height/2.0f, _defaultSprite.contentSize.width, _defaultSprite.contentSize.height);
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
}

#pragma mark - Touch Input

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    @try {
        if (self.enabled)
        {
            self.touchBeganPosition_local = [touch locationInNode:self];
            [self showHighlightedSprite];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    @try {
        
        if (self.enabled)
        {
            self.touchMovedPosition_local = [touch locationInNode:self];
            
            // Check if the touch moved out of the object's boundaries
            if (CGRectContainsPoint(self.hitboxRect, self.touchMovedPosition_local))
            {
                [self showHighlightedSprite];
            }
            // Moved out, then release
            else
            {
                [self showDefaultSprite];
            }
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    @try {
        if (self.enabled)
        {
            self.touchEndedPosition_local = [touch locationInNode:self];
            
            // Released with Active Touch
            if (CGRectContainsPoint(self.hitboxRect, self.touchEndedPosition_local))
            {
                // Notify Delegate
                [self notifyDelegateDidGetPressed];
                
                // Set to Default Image
                [self showDefaultSprite];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}


#pragma mark - Delegate Notifications

- (void)notifyDelegateDidGetPressed
{
    @try {
        if ([self.delegate respondsToSelector:@selector(arbuttonDidGetPressed:)])
        {
            [self.delegate arbuttonDidGetPressed:self];
        }
        else
        {
#ifdef DEBUG_GAME
            NSLog(@"Warning: ARButton's delegate may not be set.");
#endif
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

@end
