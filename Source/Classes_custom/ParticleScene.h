//
//  ParticleScene.h
//  ParticleSimulator
//
//  Created by Simon Chen on 11/11/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "CCScene.h"
#import "ARButton.h"
#import "Slider.h"


@interface ParticleScene : CCScene <SliderDelegate, ARButtonDelegate>

@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, strong) CCSprite *backgroundColumn;

@property (nonatomic, strong) CCNode *objectsLayer;
@property (nonatomic, strong) CCNode *backgroundLayer;

@property (nonatomic, strong) NSMutableArray *backgroundColumns;
@property (nonatomic, assign) int backgroundColumnIndex;

@property (nonatomic, assign) int numOfAttributes;
@property (nonatomic, strong) NSMutableArray *sliderTitles;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *sliderValueLabels;
@property (nonatomic, strong) NSMutableArray *particleAttributes;
@property (nonatomic, strong) CCLabelBMFont *pageLabel;

@property (nonatomic, strong) ARButton *leftArrow;
@property (nonatomic, strong) ARButton *rightArrow;

@property (nonatomic, strong) ARButton *okayButton;
@property (nonatomic, strong) ARButton *resetButton;

@property (nonatomic, strong) CCParticleSystem *particleSystem;

@property (nonatomic, assign) CGPoint originalPosition;
@property (nonatomic, assign) CGPoint startingTouchLocation;

@end
