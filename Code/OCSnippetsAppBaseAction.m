//
//  OCSnippetsAppBaseAction.m
//  Snippets-sugar
//
//  Created by Ian Beck on 6/18/10.
//  Copyright 2010 One Crayon. All rights reserved.
//

#import "OCSnippetsAppBaseAction.h"

// Makes sure we only set preference defaults once
static BOOL OCSnippetsAppPrefDefaultsConfigured = NO;

@implementation OCSnippetsAppBaseAction

- (id)init
{
	self = [super init];
	if (self == nil)
		return nil;
	
	// Run the preference setup stuff if it hasn't already happened
	if (!OCSnippetsAppPrefDefaultsConfigured) {
		// Setup the default preferences, in case they've never been modified
		NSString *defaults = [[NSBundle bundleWithIdentifier:@"com.onecrayon.sugar.snippetsapp"] pathForResource:@"Defaults" ofType:@"plist"];
		if (defaults != nil) {
			[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:defaults]];
		}
		OCSnippetsAppPrefDefaultsConfigured = YES;
	}
	
	return self;
}

@end
