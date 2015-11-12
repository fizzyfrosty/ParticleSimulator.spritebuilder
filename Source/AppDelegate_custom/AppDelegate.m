//
//  AppDelegate.m
//  Eben
//
//  Created by Simon Chen on 8/9/14.
//  Copyright Workhorse Bytes 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "IntroScene.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
    
    //[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:databaseName];

	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:@{
                                    // Show the FPS and draw call label.
                                    CCSetupShowDebugStats: @(NO),
                                    
                                    // This needs to be set up for CCClippingNode
                                    CCSetupDepthFormat:@GL_DEPTH24_STENCIL8_OES,
                                    // More examples of options you might want to fiddle with:
                                    // (See CCAppDelegate.h for more information)
                                    
                                    // Use a 16 bit color buffer:
                                    //		CCSetupPixelFormat: kEAGLColorFormatRGB565,
                                    // Use a simplified coordinate system that is shared across devices.
                                    //		CCSetupScreenMode: CCScreenModeFixed,
                                    // Run in portrait mode.
                                    //		CCSetupScreenOrientation: CCScreenOrientationPortrait,
                                    // Run at a reduced framerate.
                                    //		CCSetupAnimationInterval: @(1.0/30.0),
                                    // Run the fixed timestep extra fast.
                                    //		CCSetupFixedUpdateInterval: @(1.0/180.0),
                                    // Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
                                    CCSetupTabletScale2X: @(YES),
                                    }];
    
    // Note: this needs to happen before configureCCFileUtils is called, because we need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
    else
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif
    
    // Configure CCFileUtils to work with SpriteBuilder
    // Need to change the resource suffixes
    //[CCBReader configureCCFileUtils];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Resigned active");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] startAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[CCDirector sharedDirector] stopAnimation];
    
    // stop music
    //#music[[AudioManager sharedInstance] pauseMusic];
    
    NSLog(@"Background");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //[MagicalRecord cleanUp];
}

-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
	return [[IntroScene alloc] init];
}

@end
