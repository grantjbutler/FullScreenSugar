//
//  ESProjectWindowController_FullScreenSugar.m
//  FullScreenSugar
//
//  Created by Grant Butler on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ESProjectWindowController_FullScreenSugar.h"

@implementation ESProjectWindowController_FullScreenSugar

- (void)windowDidLoad_FullScreenSugar {
	[self windowDidLoad_FullScreenSugar];
	self.window.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
}

@end
