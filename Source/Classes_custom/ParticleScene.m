//
//  ParticleScene.m
//  ParticleSimulator
//
//  Created by Simon Chen on 11/11/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "ParticleScene.h"


@implementation ParticleScene

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    [self initializeParticleSceneData];
    
    return self;
}

- (void)initializeParticleSceneData
{
    @try {
        self.screenSize = [CCDirector sharedDirector].viewSize;
        
        self.contentSize = self.screenSize;
        
        self.userInteractionEnabled = YES;
        
        
        // Background Layer
        self.backgroundLayer = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
        [self addChild:self.backgroundLayer];
        
        // Objects Layer
        self.objectsLayer = [[CCNode alloc] init];
        [self addChild:self.objectsLayer];
        
        
        // Left column
        self.backgroundColumn = [CCSprite spriteWithImageNamed:@"background_column_ps.png"];
        self.backgroundColumn.position = ccp(self.backgroundColumn.contentSize.width/2.0f, self.screenSize.height/2.0f);
        
        [self addChild:self.backgroundColumn];
        
        
        
        
        // Initialize particle
        [self createParticle];
        
        // Font
        CCLabelBMFont *title1 = [CCLabelBMFont labelWithString:@"Testing" fntFile:font_akadylan_white_80];
        //[self.backgroundColumn addChild:title1];
        title1.position = ccp(self.backgroundColumn.contentSize.width/2.0f, self.backgroundColumn.contentSize.height - title1.contentSize.height - 20.0f);
        
        // Sliders
        self.backgroundColumns = [[NSMutableArray alloc] init];
        self.backgroundColumnIndex = -1;
        
        
        self.numOfAttributes = 26;
        self.sliderTitles = [[NSMutableArray alloc] init];
        self.sliders = [[NSMutableArray alloc] init];
        self.sliderValueLabels = [[NSMutableArray alloc] init];
        self.particleAttributes = [[NSMutableArray alloc] init];
        float initialVerticalMargin = 10.0f;
        float verticalSpacing = 10.0f;
        Slider *testSlider = [[Slider alloc] initWithLowerBound:0 upperBound:100.0f];
        
        
        for (int i = 0; i < self.numOfAttributes; i++)
        {
            
            // Create the column for every 4 attributes
            CCSprite *backgroundColumn;
            if (i % 4 == 0)
            {
                backgroundColumn = [CCSprite spriteWithImageNamed:@"background_column_ps.png"];
                backgroundColumn.position = ccp(backgroundColumn.contentSize.width/2.0f, self.screenSize.height/2.0f);
                
                
                [self.backgroundColumns addObject:backgroundColumn];
                [self addChild:backgroundColumn];
                self.backgroundColumnIndex++;
                
                // Set to be initially invisible
                backgroundColumn.visible = FALSE;
            }
            else
            {
                backgroundColumn = [self.backgroundColumns objectAtIndex:self.backgroundColumnIndex];
            }
            
            NSMutableDictionary *attributesDictionary = [self getAttributeDictionaryForIndex:i];
            
            // Attribute Title
            NSString *particleAttributeString = attributesDictionary[@"attributeString"];//[self getAttributeStringForIndex:i];
            
            CCLabelBMFont *label = [CCLabelBMFont labelWithString:particleAttributeString fntFile:font_akadylan_white_80];
            label.anchorPoint = ccp(0, 0.5f);
            
            // j is an alternate 'i' index that goes from 0-4, helping set position based on the number of this loop
            int j = i % 4;

            label.position = ccp(10.0f,self.backgroundColumn.contentSize.height - initialVerticalMargin - ((j+1) * label.contentSize.height) - ((j+1) * verticalSpacing) - ((j) * testSlider.contentSize.height));
            
            NSNumber *lowerBoundWrapper = attributesDictionary[@"lowerBound"];
            NSNumber *upperBoundWrapper = attributesDictionary[@"upperBound"];
            float lowerBound = [lowerBoundWrapper floatValue]; //[self getLowerBoundOfSliderForIndex:i];
            float upperBound = [upperBoundWrapper floatValue]; //[self getUpperBoundOfSliderForIndex:i];
            
            // Slider
            Slider *slider = [[Slider alloc] initWithLowerBound:lowerBound upperBound:upperBound];
            slider.position = ccp(self.backgroundColumn.contentSize.width/2.0f, self.backgroundColumn.contentSize.height - initialVerticalMargin - ((j+1) * label.contentSize.height) - ((j+1) * verticalSpacing) - ((j+1) * slider.contentSize.height));
            
            // Set value of slider
            if ([particleAttributeString isEqualToString:@"none"] == FALSE)
            {
                if ([particleAttributeString isEqualToString:@"posVar.x"])
                {
                    slider.value = self.particleSystem.posVar.x;
                }
                else if ([particleAttributeString isEqualToString:@"posVar.y"])
                {
                    slider.value = self.particleSystem.posVar.y;
                }
                else
                {
                    NSNumber *valueNumber = [self.particleSystem valueForKeyPath:particleAttributeString];
                    slider.value = [valueNumber floatValue];
                }
                
            }
            
            // Attribute Value label
            CCLabelBMFont *valueLabel = [CCLabelBMFont labelWithString:@"" fntFile:font_akadylan_white_80 width:slider.contentSize.width alignment:CCTextAlignmentLeft];
            valueLabel.anchorPoint = ccp(0, 0.5f);
            valueLabel.position = ccp(slider.sliderButton.position.x + 5.0f, slider.sliderButton.position.y);
            NSString *valueString = [NSString stringWithFormat:@"%.02f", slider.value];
            valueLabel.string = valueString;
            
            [slider addChild:valueLabel];
            slider.delegate = self;
            
            // Set the slider's user object to be its index
            slider.userObject = [NSNumber numberWithInt:i];
            
            if (backgroundColumn)
            {
                [backgroundColumn addChild:label];
                [backgroundColumn addChild:slider];
            }
            //[self.backgroundColumn addChild:label];
            //[self.backgroundColumn addChild:slider];
            
            
            // Set references for later use
            [self.sliderTitles addObject:label];
            [self.sliders addObject:slider];
            [self.sliderValueLabels addObject:valueLabel];
            [self.particleAttributes addObject:particleAttributeString];
        }
        
        // Arrows
        self.leftArrow = [[ARButton alloc] initWithDefaultImageNamed:@"left_arrow_ps.png" highlightedImageNamed:@"left_arrow_highlighted_ps.png"];
        self.rightArrow = [[ARButton alloc] initWithDefaultImageNamed:@"right_arrow_ps.png" highlightedImageNamed:@"right_arrow_highlighted_ps.png"];
        
        self.leftArrow.delegate = self;
        self.rightArrow.delegate = self;
        
        [self addChild:self.leftArrow];
        [self addChild:self.rightArrow];
        
        // Buttons
        self.okayButton = [[ARButton alloc] initWithDefaultImageNamed:@"okay_button_ps.png" highlightedImageNamed:@"okay_button_highlighted_ps.png"];
        self.resetButton = [[ARButton alloc] initWithDefaultImageNamed:@"reset_button_ps.png" highlightedImageNamed:@"reset_button_highlighted_ps.png"];
        
        self.okayButton.delegate = self;
        self.resetButton.delegate = self;
        
        //[self addChild:self.okayButton];
        //[self addChild:self.resetButton];
        
        
        // Positioning of Arrows and Buttons
        float bottomMargin = 10.0f;
        float horizontalMargin = 10.0f;
        self.resetButton.position = ccp(horizontalMargin + self.resetButton.contentSize.width/2.0f, bottomMargin + self.resetButton.contentSize.height/2.0f);
        
        self.okayButton.position = ccp(self.backgroundColumn.contentSize.width - horizontalMargin - self.okayButton.contentSize.width/2.0f, bottomMargin + self.okayButton.contentSize.height/2.0f);
        
        
        //self.leftArrow.position = ccp(horizontalMargin + self.leftArrow.contentSize.width/2.0f, bottomMargin + self.resetButton.contentSize.height + bottomMargin + self.leftArrow.contentSize.height/2.0f);
        //self.rightArrow.position = ccp(self.backgroundColumn.contentSize.width - horizontalMargin - self.rightArrow.contentSize.width/2.0f, bottomMargin + self.okayButton.contentSize.height + bottomMargin + self.rightArrow.contentSize.height/2.0f);
        
        self.leftArrow.position = ccp(horizontalMargin + self.leftArrow.contentSize.width/2.0f, bottomMargin + self.leftArrow.contentSize.height/2.0f);
        self.rightArrow.position = ccp(self.backgroundColumn.contentSize.width - horizontalMargin - self.rightArrow.contentSize.width/2.0f, bottomMargin + self.rightArrow.contentSize.height/2.0f);
        
        
        // Page label
        self.pageLabel = [CCLabelBMFont labelWithString:@"" fntFile:font_akadylan_white_80];
        [self addChild:self.pageLabel];
        self.pageLabel.position = ccp(self.backgroundColumn.contentSize.width/2.0f, 20);
        
        // Show the page
        [self hideAttributeSetWithIndex:self.backgroundColumnIndex];
        self.backgroundColumnIndex = 0;
        [self showAttributeSetWithIndex:self.backgroundColumnIndex];
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (NSMutableDictionary *)getAttributeDictionaryForIndex:(int)index
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    switch (index)
    {
        case 0:
            
            break;
            
        default:
            break;
    }
    
    switch (index)
    {
            // first 4
        case 0:
            dictionary[@"attributeString"] = @"angle";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:360.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
            
        case 1:
            dictionary[@"attributeString"] = @"angleVar";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:360.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 2:
            dictionary[@"attributeString"] = @"none";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:50.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 3:
            dictionary[@"attributeString"] = @"emissionRate";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1000.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
            // second 4
        case 4:
            dictionary[@"attributeString"] = @"startColor.red";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 5:
            dictionary[@"attributeString"] = @"startColor.green";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 6:
            dictionary[@"attributeString"] = @"startColor.blue";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 7:
            dictionary[@"attributeString"] = @"startColor.alpha";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 8:
            dictionary[@"attributeString"] = @"endColor.red";  // third 4
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 9:
            dictionary[@"attributeString"] = @"endColor.green";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 10:
            dictionary[@"attributeString"] = @"endColor.blue";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 11:
            dictionary[@"attributeString"] = @"endColor.alpha";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 12:
            dictionary[@"attributeString"] = @"life"; // fourth 4
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:10.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 13:
            dictionary[@"attributeString"] = @"lifeVar";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:10.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 14:
            dictionary[@"attributeString"] = @"speed";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:250.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 15:
            dictionary[@"attributeString"] = @"speedVar";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:250.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 16:
            dictionary[@"attributeString"] = @"startSize"; // fifth 4
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:100.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 17:
            dictionary[@"attributeString"] = @"startSizeVar";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:100.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 18:
            dictionary[@"attributeString"] = @"endSize";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:100.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 19:
            dictionary[@"attributeString"] = @"endSizeVar";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:100.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 20:
            dictionary[@"attributeString"] = @"startSpin"; // sixth 4
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1000.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:-1000.0f];
            break;
        case 21:
            dictionary[@"attributeString"] = @"startSpinVar";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1000.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
        case 22:
            dictionary[@"attributeString"] = @"radialAccel";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:500.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:-500.0f];
            break;
        case 23:
            dictionary[@"attributeString"] = @"radialAccelVar";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:500.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
            // seventh 4
        case 24:
            dictionary[@"attributeString"] = @"posVar.x";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:250.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0.0f];
            break;
        case 25:
            dictionary[@"attributeString"] = @"posVar.y";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:250.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0.0f];
            break;
            
        default:
            dictionary[@"attributeString"] = @"none";
            dictionary[@"upperBound"] = [NSNumber numberWithFloat:1.0f];
            dictionary[@"lowerBound"] = [NSNumber numberWithFloat:0];
            break;
    }
    
    return dictionary;
}

- (NSString *)getAttributeStringForIndex:(int)index
{
    NSString *attributeString;

    switch (index)
    {
        case 0:
            attributeString = @"angle"; // first 4
            break;
            
        case 1:
            attributeString = @"angleVar";
            break;
        case 2:
            attributeString = @"none";
            break;
        case 3:
            attributeString = @"emissionRate";
            break;
        case 4:
            attributeString = @"startColor.red"; // second 4
            break;
        case 5:
            attributeString = @"startColor.green";
            break;
        case 6:
            attributeString = @"startColor.blue";
            break;
        case 7:
            attributeString = @"startColor.alpha";
            break;
        case 8:
            attributeString = @"endColor.red";  // third 4
            break;
        case 9:
            attributeString = @"endColor.green";
            break;
        case 10:
            attributeString = @"endColor.blue";
            break;
        case 11:
            attributeString = @"endColor.alpha";
            break;
        case 12:
            attributeString = @"life"; // fourth 4
            break;
        case 13:
            attributeString = @"lifeVar";
            break;
        case 14:
            attributeString = @"speed";
            break;
        case 15:
            attributeString = @"speedVar";
            break;
        case 16:
            attributeString = @"startSize"; // fifth 4
            break;
        case 17:
            attributeString = @"startSizeVar";
            break;
        case 18:
            attributeString = @"endSize";
            break;
        case 19:
            attributeString = @"endSizeVar";
            break;
        case 20:
            attributeString = @"startSpin"; // sixth 4
            break;
        case 21:
            attributeString = @"startSpinVar";
            break;
        case 22:
            attributeString = @"radialAccel";
            break;
        case 23:
            attributeString = @"radialAccelVar";
            break;
            
        default:
            attributeString = @"none";
            break;
    }
    
    return attributeString;
}

- (float)getLowerBoundOfSliderForIndex:(int)index
{
    float lowerBound = 0;
    
    switch (index)
    {
            // .angle
        case 0:
            lowerBound = 0;
            break;
            // .lifeVar
        case 1:
            lowerBound = 0;
            break;
        case 20:
            //attributeString = @"startSpin"; // sixth 4
            lowerBound = -1000.0f;
            break;
        case 21:
            //attributeString = @"startSpinVar";
            lowerBound = -1000.0f;
            break;
        case 22:
            // radialAccel
            lowerBound = -500.0f;
            break;
        case 23:
            // radialAccelVar
            lowerBound = -500.0f;
            break;
        default:
            lowerBound = 0;
            break;
    }
    
    return lowerBound;
}

- (float)getUpperBoundOfSliderForIndex:(int)index
{
    float upperBound = 1.0f;
    
    switch (index)
    {
        case 0:
            //attributeString = @"angle";
            upperBound = 360.0f;
            break;
            
        case 1:
            //attributeString = @"angleVar";
            upperBound = 360.0f;
            break;
        case 2:
            //attributeString = @"duration";
            upperBound = 50.0f;
            break;
        case 3:
            //attributeString = @"emissionRate";
            upperBound = 1000;
            break;
        case 4:
            //attributeString = @"startColor.red";
            upperBound = 1.0f;
            break;
        case 5:
            //attributeString = @"startColor.green";
            upperBound = 1.0f;
            break;
        case 6:
            //attributeString = @"startColor.blue";
            upperBound = 1.0f;
            break;
        case 7:
            //attributeString = @"startColor.alpha";
            upperBound = 1.0f;
            break;
        case 8:
            //attributeString = @"endColor.red";  // third 4
            upperBound = 1.0f;
            break;
        case 9:
            //attributeString = @"endColor.green";
            upperBound = 1.0f;
            break;
        case 10:
            //attributeString = @"endColor.blue";
            upperBound = 1.0f;
            break;
        case 11:
            //attributeString = @"endColor.alpha";
            upperBound = 1.0f;
            break;
        case 12:
            //attributeString = @"life"; // fourth 4
            upperBound = 10.0f;
            break;
        case 13:
            //attributeString = @"lifeVar";
            upperBound = 10.0f;
            break;
        case 14:
            //attributeString = @"speed";
            upperBound = 250.0f;
            break;
        case 15:
            //attributeString = @"speedVar";
            upperBound = 250.0f;
            break;
        case 16:
            //attributeString = @"startSize"; // fifth 4
            upperBound = 100.0f;
            break;
        case 17:
            //attributeString = @"startSizeVar";
            upperBound = 100.0f;
            break;
        case 18:
            //attributeString = @"endSize";
            upperBound = 100.0f;
            break;
        case 19:
            //attributeString = @"endSizeVar";
            upperBound = 100.0f;
            break;
        case 20:
            //attributeString = @"startSpin"; // sixth 4
            upperBound = 1000.0f;
            break;
        case 21:
            //attributeString = @"startSpinVar";
            upperBound = 1000.0f;
            break;
        case 22:
            //attributeString = @"radialAccel";
            upperBound = 500.0f;
            break;
        case 23:
            //attributeString = @"radialAccelVar";
            upperBound = 500.0f;
            break;

        default:
            //attributeString = @"none";
            upperBound = 1.0f;
            break;
    }

    
    return upperBound;
}

- (void)createParticle
{
    @try {
        //
        //CCParticleSystem *particleSystem = [[CCParticleSystem alloc] initWithFile:@"cloud_particle.png"];
        //self.particleSystem = [[CCParticleSystem alloc] initWithTotalParticles:600];
        self.particleSystem = [[CCParticleSmoke alloc] initWithTotalParticles:1000];
        
        // Gravity Mode
        //self.particleSystem.emitterMode = CCParticleSystemModeGravity;
        //self.particleSystem.gravity = ccp(0, 1.0f);
        
        
        //particleSystem.posVar = ccp(self.player.aoeRadius.contentSize.width/2.0f, self.player.aoeRadius.contentSize.height/2.0f);
        self.particleSystem.texture = [CCTexture textureWithFile:@"smoke_particle.png"];
        self.particleSystem.life = 2.750f;
        self.particleSystem.lifeVar = 0.25f;
        self.particleSystem.autoRemoveOnFinish = NO; // this produces bug of not showing up sometimes
        //particleSystem.duration = 0.1f;
        self.particleSystem.duration = -1.0f;
        self.particleSystem.speed = 100;
        self.particleSystem.startSize = 50;
        self.particleSystem.startSizeVar = 5;
        self.particleSystem.endSize = 10;
        self.particleSystem.angleVar = 60;
        self.particleSystem.particlePositionType = CCParticleSystemPositionTypeRelative;
        
        self.particleSystem.emissionRate = 50.0f;
        self.particleSystem.startColor = [CCColor whiteColor];
        

        
        [self.objectsLayer addChild:self.particleSystem];
        
        self.particleSystem.position = ccp(self.contentSize.width * 2.0f/3.0f, self.contentSize.height/2.0f);
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)showAttributeSetWithIndex:(int)index
{
    @try {
        CCSprite *backgroundColumn = [self.backgroundColumns objectAtIndex:index];
        backgroundColumn.visible = TRUE;
        
        // Set page label
        self.pageLabel.visible = TRUE;
        NSString *pageString = [NSString stringWithFormat:@"%d/%d", self.backgroundColumnIndex+1, self.backgroundColumns.count];
        self.pageLabel.string = pageString;

    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)hideAttributeSetWithIndex:(int)index
{
    @try {
        CCSprite *backgroundColumn = [self.backgroundColumns objectAtIndex:index];
        backgroundColumn.visible = FALSE;
        
        self.pageLabel.visible = FALSE;
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)showNextAttributeSet
{
    @try {
        // Make sure it does not go past index
        if ((self.backgroundColumnIndex + 1) <= (self.backgroundColumns.count - 1))
        {
            [self hideAttributeSetWithIndex:self.backgroundColumnIndex];
            
            // Show the next set of attributes
            self.backgroundColumnIndex++;
            
            [self showAttributeSetWithIndex:self.backgroundColumnIndex];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)showPreviousAttributeSet
{
    @try {
        // Make sure it does not go past index
        if ((self.backgroundColumnIndex -1) >= 0)
        {
            [self hideAttributeSetWithIndex:self.backgroundColumnIndex];
            
            // Show the next set of attributes
            self.backgroundColumnIndex--;
            
            [self showAttributeSetWithIndex:self.backgroundColumnIndex];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}


#pragma mark - Touch Input

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    self.startingTouchLocation = [touch locationInWorld];
    self.originalPosition = self.objectsLayer.position;
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint location = [touch locationInWorld];
    CGPoint deltaDistance = ccpSub(location, self.startingTouchLocation);
    
    self.objectsLayer.position = ccpAdd(self.originalPosition, deltaDistance);
}


#pragma mark - delegate callbacks
- (void)sliderDidMove:(Slider *)slider value:(float)value
{
    @try {
        // Update the value of slider label
        NSNumber *sliderIndexWrapper = slider.userObject;
        int sliderIndex = [sliderIndexWrapper intValue];
        
        CCLabelBMFont *sliderValueLabel = [self.sliderValueLabels objectAtIndex:sliderIndex];
        sliderValueLabel.position = ccp(slider.sliderButton.position.x + 5.0f, slider.sliderButton.position.y);
        NSString *string = [NSString stringWithFormat:@"%.02f", value];
        sliderValueLabel.string = string;
        
        
        // Update attribute of the particle system
        NSString *attributeKey = [self.particleAttributes objectAtIndex:sliderIndex];
        NSNumber *attributeValue = [NSNumber numberWithFloat:value];
        
        if ([attributeKey isEqualToString:@"startColor.red"])
        {
            //[self.particleSystem.startColor setValue:attributeValue forKey:@"red"];
            CCColor *color = [CCColor colorWithRed:[attributeValue floatValue] green:self.particleSystem.startColor.green blue:self.particleSystem.startColor.blue alpha:self.particleSystem.startColor.alpha];
            self.particleSystem.startColor = color;
        }
        else if ([attributeKey isEqualToString:@"startColor.green"])
        {
            //[self.particleSystem.startColor setValue:attributeValue forKey:@"red"];
            CCColor *color = [CCColor colorWithRed:self.particleSystem.startColor.red green:[attributeValue floatValue] blue:self.particleSystem.startColor.blue alpha:self.particleSystem.startColor.alpha];
            self.particleSystem.startColor = color;
        }
        else if ([attributeKey isEqualToString:@"startColor.blue"])
        {
            //[self.particleSystem.startColor setValue:attributeValue forKey:@"red"];
            CCColor *color = [CCColor colorWithRed:self.particleSystem.startColor.red green:self.particleSystem.startColor.green blue:[attributeValue floatValue] alpha:self.particleSystem.startColor.alpha];
            self.particleSystem.startColor = color;
        }
        else if ([attributeKey isEqualToString:@"startColor.alpha"])
        {
            CCColor *color = [CCColor colorWithRed:self.particleSystem.startColor.red green:self.particleSystem.startColor.green blue:self.particleSystem.startColor.blue alpha:[attributeValue floatValue]];
            self.particleSystem.startColor = color;
        }
        else if ([attributeKey isEqualToString:@"endColor.red"])
        {
            //[self.particleSystem.endColor setValue:attributeValue forKey:@"red"];
            CCColor *color = [CCColor colorWithRed:[attributeValue floatValue] green:self.particleSystem.endColor.green blue:self.particleSystem.endColor.blue alpha:self.particleSystem.endColor.alpha];
            self.particleSystem.endColor = color;
        }
        else if ([attributeKey isEqualToString:@"endColor.green"])
        {
            //[self.particleSystem.endColor setValue:attributeValue forKey:@"red"];
            CCColor *color = [CCColor colorWithRed:self.particleSystem.endColor.red green:[attributeValue floatValue] blue:self.particleSystem.endColor.blue alpha:self.particleSystem.endColor.alpha];
            self.particleSystem.endColor = color;
        }
        else if ([attributeKey isEqualToString:@"endColor.blue"])
        {
            //[self.particleSystem.endColor setValue:attributeValue forKey:@"red"];
            CCColor *color = [CCColor colorWithRed:self.particleSystem.endColor.red green:self.particleSystem.endColor.green blue:[attributeValue floatValue] alpha:self.particleSystem.endColor.alpha];
            self.particleSystem.endColor = color;
        }
        else if ([attributeKey isEqualToString:@"endColor.alpha"])
        {
            CCColor *color = [CCColor colorWithRed:self.particleSystem.endColor.red green:self.particleSystem.endColor.green blue:self.particleSystem.endColor.blue alpha:[attributeValue floatValue]];
            self.particleSystem.endColor = color;
        }
        else if ([attributeKey isEqualToString:@"posVar.x"])
        {
            CGPoint posVar = ccp([attributeValue floatValue], self.particleSystem.posVar.y);
            self.particleSystem.posVar = posVar;
        }
        else if ([attributeKey isEqualToString:@"posVar.y"])
        {
            CGPoint posVar = ccp(self.particleSystem.posVar.x, [attributeValue floatValue]);
            self.particleSystem.posVar = posVar;
        }
        else
        {
            [self.particleSystem setValue:attributeValue forKeyPath:attributeKey];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)arbuttonDidGetPressed:(ARButton *)button
{
    @try {
        if (button == self.okayButton)
        {
            
        }
        else if (button == self.leftArrow)
        {
            [self showPreviousAttributeSet];
        }
        else if (button == self.rightArrow)
        {
            [self showNextAttributeSet];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@(): %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}


@end
