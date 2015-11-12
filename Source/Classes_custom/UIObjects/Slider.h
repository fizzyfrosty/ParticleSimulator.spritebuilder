//
//  Slider.h
//  Janus
//
//  Created by Simon Chen on 3/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@class Slider;

@protocol SliderDelegate <NSObject>

@optional
- (void)sliderDidGetTouched:(Slider *)slider value:(float)value;
- (void)sliderDidGetReleased:(Slider *)slider value:(float)value;
- (void)sliderDidMove:(Slider *)slider value:(float)value;

@end


@interface Slider : CCNode


- (instancetype)init;
- (instancetype)initWithLowerBound:(float)lowerBound upperBound:(float)upperBound;
- (void)setValue:(float)value;


@property (nonatomic, assign) float lowerBound;
@property (nonatomic, assign) float upperBound;
@property (nonatomic, assign, setter=setValue:) float value;

@property (nonatomic, strong) CCSprite *sliderBar;
@property (nonatomic, strong) CCSprite *sliderButton;
@property (nonatomic, assign) BOOL sliderButtonIsTouched;

@property (nonatomic, weak) id<SliderDelegate> delegate;

@end
