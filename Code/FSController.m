//
//  FSController.m
//  FullScreenSugar
//
//  Created by Grant Butler on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FSController.h"

#import "ESProjectWindowController_FullScreenSugar.h"
#import "EKDocumentWindowController_FullScreenSugar.h"
#import "MRTabbedWindow_FullScreenSugar.h"

#import <objc/runtime.h>

void egotmfs_appendMethod(Class aClass, Class bClass, SEL bSel);
BOOL egotmfs_methodSwizzle(Class klass, SEL origSel, SEL altSel, BOOL forInstance);

static BOOL hasSwizzled = NO;

@implementation FSController

+ (FSController *)sharedController {
	static FSController *sharedController = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedController = [[FSController alloc] init];
	});
	
	return sharedController;
}

+ (void)load {
	[FSController sharedController];
}

- (id)init {
	if((self = [super init])) {
		if(!hasSwizzled) {
			egotmfs_appendMethod(NSClassFromString(@"ESProjectWindowController"), [ESProjectWindowController_FullScreenSugar class], @selector(windowDidLoad_FullScreenSugar));
			egotmfs_methodSwizzle(NSClassFromString(@"ESProjectWindowController"), @selector(windowDidLoad), @selector(windowDidLoad_FullScreenSugar), YES);
			
			egotmfs_appendMethod(NSClassFromString(@"EKDocumentWindowController"), [EKDocumentWindowController_FullScreenSugar class], @selector(windowDidLoad_FullScreenSugar));
			egotmfs_methodSwizzle(NSClassFromString(@"EKDocumentWindowController"), @selector(windowDidLoad), @selector(windowDidLoad_FullScreenSugar), YES);
			
			egotmfs_appendMethod(NSClassFromString(@"MRTabbedWindow"), [MRTabbedWindow_FullScreenSugar class], @selector(initWithContentRect_FullScreenSugar:styleMask:backing:defer:));
			egotmfs_methodSwizzle(NSClassFromString(@"MRTabbedWindow"), @selector(initWithContentRect:styleMask:backing:defer:), @selector(initWithContentRect_FullScreenSugar:styleMask:backing:defer:), YES);
			
			hasSwizzled = YES;
			
			for(NSWindow* window in [NSApplication sharedApplication].windows) {
				if([window.windowController isKindOfClass:NSClassFromString(@"ESProjectWindowController")] || 
				   [window.windowController isKindOfClass:NSClassFromString(@"EKDocumentWindowController")]) {
					window.collectionBehavior |= NSWindowCollectionBehaviorFullScreenPrimary;
				}
			}
		}
    }
    
    return self;
}

@end

#pragma mark -
#pragma mark Method swizzling

void egotmfs_appendMethod(Class aClass, Class bClass, SEL bSel) {
	if(!aClass) return;
	if(!bClass) return;
	Method bMethod = class_getInstanceMethod(bClass, bSel);
	class_addMethod(aClass, method_getName(bMethod), method_getImplementation(bMethod), method_getTypeEncoding(bMethod));
}

/**
 * @credit http://www.cocoadev.com/index.pl?MethodSwizzling
 */
BOOL egotmfs_methodSwizzle(Class klass, SEL origSel, SEL altSel, BOOL forInstance) {
    // Make sure the class isn't nil
	if (klass == nil)
		return NO;
	
	// Look for the methods in the implementation of the immediate class
	Class iterKlass = (forInstance ? klass : klass->isa);
	Method origMethod = NULL, altMethod = NULL;
	unsigned int methodCount = 0;
	Method *mlist = class_copyMethodList(iterKlass, &methodCount);
	if(mlist != NULL) {
		int i;
		for (i = 0; i < methodCount; ++i) {
			if(method_getName(mlist[i]) == origSel )
				origMethod = mlist[i];
			if (method_getName(mlist[i]) == altSel)
				altMethod = mlist[i];
		}
	}
	
	// if origMethod was not found, that means it is not in the immediate class
	// try searching the entire class hierarchy with class_getInstanceMethod
	// if not found or not added, bail out
	if(origMethod == NULL) {
		origMethod = class_getInstanceMethod(iterKlass, origSel);
		if(origMethod == NULL) {
			return NO;
		}
		
		if(class_addMethod(iterKlass, method_getName(origMethod), method_getImplementation(origMethod), method_getTypeEncoding(origMethod)) == NO) {
			return NO;
		}
	}
	
	// same thing with altMethod
	if(altMethod == NULL) {
		altMethod = class_getInstanceMethod(iterKlass, altSel);
		if(altMethod == NULL ) 
			return NO;
		if(class_addMethod(iterKlass, method_getName(altMethod), method_getImplementation(altMethod), method_getTypeEncoding(altMethod)) == NO )
			return NO;
	}
	
	//clean up
	free(mlist);
	
	// we now have to look up again for the methods in case they were not in the class implementation,
	//but in one of the superclasses. In the latter, that means we added the method to the class,
	//but the Leopard APIs is only 'class_addMethod', in which case we need to have the pointer
	//to the Method objects actually stored in the Class structure (in the Tiger implementation, 
	//a new mlist was explicitely created with the added methods and directly added to the class; 
	//thus we were able to add a new Method AND get the pointer to it)
	
	// for simplicity, just use the same code as in the first step
	origMethod = NULL;
	altMethod = NULL;
	methodCount = 0;
	mlist = class_copyMethodList(iterKlass, &methodCount);
	if(mlist != NULL) {
		int i;
		for (i = 0; i < methodCount; ++i) {
			if(method_getName(mlist[i]) == origSel )
				origMethod = mlist[i];
			if (method_getName(mlist[i]) == altSel)
				altMethod = mlist[i];
		}
	}
	
	// bail if one of the methods doesn't exist anywhere
	// with all we did, this should not happen, though
	if (origMethod == NULL || altMethod == NULL)
		return NO;
	
	// now swizzle
	method_exchangeImplementations(origMethod, altMethod);
	
	//clean up
	free(mlist);
	
	return YES;
}
