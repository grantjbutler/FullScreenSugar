//
//  MRTabbedWindow_FullScreenSugar.m
//  FullScreenSugar
//
//  Created by Grant Butler on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MRTabbedWindow_FullScreenSugar.h"

@implementation MRTabbedWindow_FullScreenSugar

- (id)initWithContentRect_FullScreenSugar:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	self = [self initWithContentRect_FullScreenSugar:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	self.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
	return self;
}

@end
