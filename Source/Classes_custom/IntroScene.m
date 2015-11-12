//
//  IntroScene.m
//  ParticleSimulator
//
//  Created by Simon Chen on 11/11/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "IntroScene.h"
#import "ParticleScene.h"
#import "MBProgressHUD.h"

@implementation IntroScene

- (instancetype)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    @try {
        CGSize screenSize = [CCDirector sharedDirector].viewSize;
        
        // Add background as splash
        CCSprite *background = [CCSprite spriteWithImageNamed:@"whbyteslogo.png"];
        background.positionType = CCPositionTypeNormalized;
        background.position = ccp(0.5f, 0.5f);
        [self addChild:background];
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        hud.labelText = @"Loading";
        hud.yOffset = screenSize.height/2.0f * 4.0f/5.0f;
        hud.removeFromSuperViewOnHide = YES;
        
        // Loading Bar with MBProgressHud
        [self cacheDataWithProgressCallback:^(float progress) {
            hud.progress = progress;
            
        } completion:^{
            // Hide progress hud
            [hud hide:YES];
            
            [self scheduleOnce:@selector(transitionToParticleScene) delay:0.5f];
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
    
    
    // done
    return self;
}

- (void)cacheDataWithProgressCallback:(void (^)(float progress))callback completion:(void (^)(void))completion
{
    @try {
        // Delay the update
        __block float delay = 0;;
        
        [self scheduleBlock:^(CCTimer *timer) {
            __block float cacheProgress = 0;
            
            // So we're going to call the callback multiple times
            [self cacheSpriteFrames];
            cacheProgress = 0.5f;
            callback(cacheProgress);
            
            delay += 0.25f;
            [self scheduleBlock:^(CCTimer *timer) {
                completion();
            } delay:delay];
            
            /*
            delay += 0.25f;
            [self scheduleBlock:^(CCTimer *timer) {
                [VollyGameManager cacheSpriteFrames];
                cacheProgress = 0.75f;
                callback(cacheProgress);
            } delay:delay];
            
            delay += 0.25f;
            [self scheduleBlock:^(CCTimer *timer) {
                [VollyAssetManager patchData];
                cacheProgress = 1.0f;
                callback(cacheProgress);
            } delay:delay];
            
            delay += 0.25f;
            [self scheduleBlock:^(CCTimer *timer) {
                // finished
                completion();
            } delay:delay];
             */
            
        } delay:0.25f ];

    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

- (void)cacheSpriteFrames
{
    @try {
        CCTexture *temporaryLoadTexture;
        
        // Cache the frames from the plist file
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"particle_spritesheet.plist"];
        temporaryLoadTexture = [CCTexture textureWithFile:@"particle_spritesheet.png"];
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
    
}

- (void)transitionToParticleScene
{
    @try {
        [[CCDirector sharedDirector] replaceScene:[[ParticleScene alloc] init]withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
    }
    @catch (NSException *exception) {
        NSLog(@"Error at %@.%@: %@()", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception.description);
    }
}

@end
