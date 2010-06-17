//
//  OCSnippetsAppConnector.m
//  Snippets-sugar
//
//  Created by Ian Beck on 6/15/10.
//  Copyright 2010 One Crayon. All rights reserved.
//

#import "OCSnippetsAppConnector.h"
#import "SASnippetsBridge.h"
#import <EspressoTextActions.h>
#import <EspressoTextCore.h>

@implementation OCSnippetsAppConnector

@synthesize actionContext;

- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
	self = [super init];
	if (self == nil)
		return nil;
	
	return self;
}

- (BOOL)canPerformActionWithContext:(id)context
{
	return YES;
}

- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
	SASnippetsBridge *bridge = [SASnippetsBridge sharedBridge];
	if (bridge == nil) {
		// No bridge, which means Snippets isn't running; launch it
		return [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.snippetsapp.Snippets" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifier:NULL];
	}
	
	// If we get here, we have a bridge to work with, so move forward
	
	// Save our context
	[self setActionContext:context];
	
	// TEMP: set this in a preference screen
	SASnippetsMode mode = kSASnippetsModeGlobalMenu;
	
	// These Bridge APIs will open the Search Panel or the Global Menu if Snippets is running
	[bridge selectSnippetUsingMode:mode handler:^(NSDictionary *selectedSnippet)
	 {
		 // And this block will be executed if a User selects any snippet from the Search Panel or the Global Menu
		 [self snippetInsertCallback:[selectedSnippet objectForKey:kSASnippetSourceCode]];
	 }];
	return YES;
}

- (NSString *)titleWithContext:(id)actionContext
{
	if ([SASnippetsBridge sharedBridge] == nil) {
		return @"Launch Snippets.app";
	} else {
		return nil;
	}
}

- (void)snippetInsertCallback:(NSString *)snippet
{
	// TODO: Add some logic to convert named Snippets placeholders into tab stops?
	[[self actionContext] insertTextSnippet:[CETextSnippet snippetWithString:snippet]];
}

- (void)dealloc
{
	[self setActionContext:nil];
	[super dealloc];
}

@end