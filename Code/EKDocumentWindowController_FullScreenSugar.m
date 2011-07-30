//
//  EKDocumentWindowController_FullScreenSugar.m
//  FullScreenSugar
//
//  Created by Grant Butler on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EKDocumentWindowController_FullScreenSugar.h"

@implementation EKDocumentWindowController_FullScreenSugar

- (void)windowDidLoad_FullScreenSugar {
	[self windowDidLoad_FullScreenSugar];
	self.window.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
}

@end
