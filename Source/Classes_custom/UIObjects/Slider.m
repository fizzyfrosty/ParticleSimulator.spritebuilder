//
//  Slider.m
//  Janus
//
//  Created by Simon Chen on 3/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Slider.h"



@implementation Slider

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    @try {
        [self initializeSliderData];
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
    
    return self;
}


- (instancetype)initWithLowerBound:(float)lowerBound upperBound:(float)upperBound
{
    self = [super init];
    if (!self) return nil;
    
    @try {
        [self initializeSliderData];
        
        _lowerBound = lowerBound;
        _upperBound = upperBound;
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
    
    return self;
}

- (void)initializeSliderData
{
    @try {
        _lowerBound = 0;
        _upperBound = 1.0f;
        _value = 0.5f;
        
        self.userInteractionEnabled = YES;
        
        // Add the slider bar
        _sliderBar = [CCSprite spriteWithImageNamed:@"slider_bar_ps.png"];
        [self addChild:self.sliderBar];
        
        // Add the node
        _sliderButton = [CCSprite spriteWithImageNamed:@"slider_circle_ps.png"];
        [self addChild:self.sliderButton];
        
        
        self.contentSize = CGSizeMake(self.sliderBar.contentSize.width, self.sliderButton.contentSize.height);
        
        self.sliderBar.position = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
        self.sliderButton.position = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
        

        self.anchorPoint = ccp(0.5f, 0.5f);
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    @try {
        CGPoint location = [touch locationInNode:self];
        CGRect sliderButtonRect = CGRectMake(self.sliderButton.position.x - self.sliderButton.contentSize.width/2.0f, self.sliderButton.position.y - self.sliderButton.contentSize.height/2.0f, self.sliderButton.contentSize.width, self.sliderButton.contentSize.height);
        
        // If touched slider button, enlarge, make moveable
        if (CGRectContainsPoint(sliderButtonRect, location))
        {
            self.sliderButton.scale = 1.25f;
            self.sliderButtonIsTouched = TRUE;
            
            [self notifyDelegateDidTouch];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}


- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    @try {
        CGPoint location = [touch locationInNode:self];
        
        // Move slider button if touched
        if (self.sliderButtonIsTouched == TRUE)
        {
            self.sliderButton.position = ccp(location.x, self.sliderButton.position.y);
            
            // Clamp positions
            if (self.sliderButton.position.x <= self.sliderButton.contentSize.width/2.0f)
            {
                self.sliderButton.position = ccp(self.sliderButton.contentSize.width/2.0f, self.sliderButton.position.y);
            }
            else if (self.sliderButton.position.x >= (self.contentSize.width - self.sliderButton.contentSize.width/2.0f))
            {
                float xPosition = self.contentSize.width - self.sliderButton.contentSize.width/2.0f;
                self.sliderButton.position = ccp(xPosition, self.sliderButton.position.y);
            }
            
            // Calculate value
            CGPoint point1 = ccp(self.sliderButton.contentSize.width/2.0f, self.lowerBound);
            CGPoint point2 = ccp(self.contentSize.width - self.sliderButton.contentSize.width/2.0f, self.upperBound);
            
            _value = [self getYValueWithX:self.sliderButton.position.x point1:point1 point2:point2];
            
            [self notifyDelegateDidMove];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    @try {
        // If released slider button, back to normal size, make not moveable
        if (self.sliderButtonIsTouched == TRUE)
        {
            self.sliderButtonIsTouched = FALSE;
            self.sliderButton.scale = 1.0f;
            
            [self notifyDelegateDidRelease];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (float)getYValueWithX:(float)x point1:(CGPoint)point1 point2:(CGPoint)point2
{
    @try {
        /*
         y = mx + b
         m = (p2.y - p1.y)/(p2.x - p1.x)
         
         y = m * x + b
         b = p1.y - (m * p1.x)
         
         y = m * x + b
         */
        float slope = (point2.y - point1.y) / (point2.x - point1.x);
        float yIntercept = point1.y - (slope * point1.x);
        float output = slope * x + yIntercept;
        
        return output;
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (float)getXValueWithY:(float)y point1:(CGPoint)point1 point2:(CGPoint)point2
{
    @try {
        /*
         y = mx + b
         m = (p2.y - p1.y)/(p2.x - p1.x)
         
         y = m * x + b
         b = p1.y - (m * p1.x)
         
         y = m * x + b
         */
        float slope = (point2.y - point1.y) / (point2.x - point1.x);
        float yIntercept = point1.y - (slope * point1.x);
        
        float x = (y - yIntercept) / slope;
        //float output = slope * x + yIntercept;
        
        return x;
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)setValue:(float)value
{
    @try {
        _value = value;
        
        // Move the slider button
        // Calculate value
        CGPoint point1 = ccp(self.sliderButton.contentSize.width/2.0f, self.lowerBound);
        CGPoint point2 = ccp(self.contentSize.width - self.sliderButton.contentSize.width/2.0f, self.upperBound);
        
        float xPosition = [self getXValueWithY:value point1:point1 point2:point2];
        
        self.sliderButton.position = ccp(xPosition, self.sliderButton.position.y);
        
        [self notifyDelegateDidRelease];
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)notifyDelegateDidMove
{
    @try {
        if ([self.delegate respondsToSelector:@selector(sliderDidMove:value:)])
        {
            [self.delegate sliderDidMove:self value:self.value];
        }
        else
        {
#ifdef DEBUG_GAME
            NSLog(@"Warning: Slider delegate may not be set.");
#endif
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)notifyDelegateDidTouch
{
    @try {
        if ([self.delegate respondsToSelector:@selector(sliderDidGetTouched:value:)])
        {
            [self.delegate sliderDidGetTouched:self value:self.value];
        }
        else
        {
#ifdef DEBUG_GAME
            NSLog(@"Warning: Slider delegate may not be set.");
#endif
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)notifyDelegateDidRelease
{
    @try {
        if ([self.delegate respondsToSelector:@selector(sliderDidGetReleased:value:)])
        {
            [self.delegate sliderDidGetReleased:self value:self.value];
        }
        else
        {
#ifdef DEBUG_GAME
            NSLog(@"Warning: Slider delegate may not be set.");
#endif
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

@end
