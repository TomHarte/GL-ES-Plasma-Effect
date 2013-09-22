//
//  ESPPlasmaViewController.m
//  GL ES Plasma
//
//  Created by Thomas Harte on 21/09/2013.
//  Copyright (c) 2013 Thomas Harte. All rights reserved.
//

#import "ESPPlasmaViewController.h"
#import "PlasmaView.h"
#import <QuartzCore/QuartzCore.h>

@interface ESPPlasmaViewController ()

@property (nonatomic, weak) IBOutlet ESPPlasmaView *plasmaView;

@end

@implementation ESPPlasmaViewController
{
	CADisplayLink *_displayLink;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawNewFrame)];
	[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[_displayLink invalidate];
	_displayLink = nil;
}

- (void)drawNewFrame
{
	// let's make one minute the duration of a full cycle of the animation
	self.plasmaView.time = [NSDate timeIntervalSinceReferenceDate] / 60.0;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

@end
