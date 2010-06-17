//
//  SASnippetsBridge.m
//  SnippetsClient
//
//  Created by Vadim Shpakovski on 15/06/2010.
//  Copyright 2010 Lucky Ants. All rights reserved.
//

#import "SASnippetsBridge.h"

static NSString *const kSASnippetsNotificationName = @"SASnippetsNotification";
static NSString *const kSASnippetsAppObject = @"SASnippetsAppObject";
static NSString *const kSASnippetsMode = @"SASnippetsMode";

NSString *const kSASnippetSourceCode = @"SASnippetSourceCode";

@interface SASnippetsBridge ()

@property (copy) SASnippetsHandler _selectionHandler;
@property (copy) NSString *_postbackNotificationName;

@end

#pragma mark -

@implementation SASnippetsBridge

@synthesize _selectionHandler;
@synthesize _postbackNotificationName;

#pragma mark -
#pragma mark Singleton

static SASnippetsBridge *sharedBridge = nil;

+ (SASnippetsBridge *)sharedBridge;
{
    @synchronized(self)
    {
        if (!sharedBridge)
            sharedBridge = [[self alloc] init];
    }
    return sharedBridge;
}

#pragma mark -

+ (id)allocWithZone:(NSZone *)zone;
{
    @synchronized(self)
    {
        if (!sharedBridge)
        {
            sharedBridge = [super allocWithZone:zone];
            return sharedBridge;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone;
{
    return self;
}

- (id)retain;
{
    return self;
}

- (NSUInteger)retainCount;
{
    return NSUIntegerMax;
}

- (void)release;
{
}

- (id)autorelease;
{
	return self;
}

#pragma mark -
#pragma mark Private methods

- (void)_cleanupNotificationDispatchTable;
{
    if (!self._postbackNotificationName) return;
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:self._postbackNotificationName object:kSASnippetsAppObject];
    self._postbackNotificationName = nil;
}

- (void)_snippetsDidSelect:(NSNotification *)notification;
{
    // Cleanup notification center after previous selection request
    [self _cleanupNotificationDispatchTable];
    
    // Notification's user info includes contains information about selected snippet
    if (self._selectionHandler)
    {
        self._selectionHandler([notification userInfo]);
        self._selectionHandler = nil;
    }
}

#pragma mark -
#pragma mark Public interface

- (void)selectSnippetUsingMode:(SASnippetsMode)menubarMode handler:(SASnippetsHandler)selectionHandler;
{
    // Cleanup notification center after previous selection request
    [self _cleanupNotificationDispatchTable];
    
    // Remember selection handler to call it during postback notification
    self._selectionHandler = selectionHandler;
    if (!self._selectionHandler) return;
    
    // Generate new name for postback notification and post selection request
    self._postbackNotificationName = [NSString stringWithFormat:@"%@-%@",
                                      [[NSBundle mainBundle] bundleIdentifier],
                                      [[NSProcessInfo processInfo] globallyUniqueString]];
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    
    // Wait for response from Snippets application
    [dnc addObserver:self selector:@selector(_snippetsDidSelect:) name:self._postbackNotificationName
              object:kSASnippetsAppObject suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    
    // Ask Snippets to run the menubar panel and select snippet
    NSDictionary *mode = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:menubarMode] forKey:kSASnippetsMode];
    [dnc postNotificationName:kSASnippetsNotificationName object:self._postbackNotificationName userInfo:mode];
}

@end
