//
//  OCSnippetsAppConnector.m
//  Snippets-sugar
//
//  Created by Ian Beck on 6/15/10.
//  Copyright 2010 One Crayon. All rights reserved.
//

#import "OCSnippetsAppConnector.h"
#import "SASnippetsBridge.h"
#import "RegexKitLite.h"
#import <EspressoTextActions.h>
#import <EspressoTextCore.h>

// Makes sure we only set preference defaults once
static BOOL OCSnippetsAppPrefDefaultsConfigured = NO;

// Logical enums for checking preference values
typedef enum {
    kOCSnippetsPlaceholderAutodetect = 0,
    kOCSnippetsPlaceholderNamed = 1,
	kOCSnippetsPlaceholderNumeric = 2,
	kOCSnippetsPlaceholderNone = 3
} OCSnippetsPlaceholderStyle;

@implementation OCSnippetsAppConnector

@synthesize actionContext;

- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
	self = [super init];
	if (self == nil)
		return nil;
	
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
	
	// Fetch the preferred method for inserting snippets
	SASnippetsMode mode = kSASnippetsModeSearchPanel;
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"SnippetsAppInsertMode"] == 1) {
		mode = kSASnippetsModeGlobalMenu;
	}
	
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
	// Check to see what placeholders the user prefers
	/* Options:
	     0: Autodetect
	     1: Snippets.app
	     2: Espresso/Textmate
	     3: Plain text
	 */
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	OCSnippetsPlaceholderStyle placeholders = [defaults integerForKey:@"SnippetsAppPlaceholderStyle"];
	// If we need to autodetect, do so
	if (placeholders == kOCSnippetsPlaceholderAutodetect) {
		if ([snippet isMatchedByRegex:@"(?s)^.*?\\$\\{\\{?[a-zA-Z][a-zA-Z0-9_ -]*:.*?\\}?\\}.*$"]) {
			// We found a Snippets-style placeholder, so use Named
			placeholders = kOCSnippetsPlaceholderNamed;
		} else if ([snippet	isMatchedByRegex:@"(?s)^.*?(\\$[0-9]|\\$\\{[0-9]+:.+?\\}).*$"]) {
			// We found a numeric placeholder, so use Numeric
			placeholders = kOCSnippetsPlaceholderNumeric;
		} else {
			// No placeholders, so assume it's plain text (safest that way; don't lose PHP variables and so forth)
			placeholders = kOCSnippetsPlaceholderNone;
		}
	}
	
	if (placeholders == kOCSnippetsPlaceholderNamed) {
		// Because named placeholders only use tab stops, we need to escape everything
		snippet = [snippet stringByReplacingOccurrencesOfRegex:@"(\\$|\\{|\\}|`)" withString:@"\\\\$1"];
		
		// Convert named placeholders into numeric tab stops
		// First grab the captures so we can pare down to the actual tab stops
		NSArray *captureGroups = [snippet arrayOfCaptureComponentsMatchedByRegex:@"\\\\\\$\\\\\\{(?:\\\\\\{)?([a-zA-Z0-9_ -]+)(:.*?)?(?:\\\\\\})?\\\\\\}"];
		NSMutableArray *namedPlaceholders = [NSMutableArray arrayWithCapacity:[captureGroups count]];
		for (NSArray *captureGroup in captureGroups) {
			NSString *placeholderName = [captureGroup objectAtIndex:1];
			if (![namedPlaceholders containsObject:placeholderName]) {
				[namedPlaceholders addObject:placeholderName];
			}
		}
		// We now have a list of every unique placeholder name; loop over them and do our replacements
		NSUInteger stopNumber = 1;
		for (NSString *namedPlaceholder in namedPlaceholders) {
			// Replace all occurrences
			snippet = [snippet stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"\\\\\\$\\\\\\{(?:\\\\\\{)?%@(:.*?)?(?:\\\\\\})?\\\\\\}", namedPlaceholder] withString:[NSString stringWithFormat:@"${%lu$1}", (unsigned long)stopNumber]];
			stopNumber++;
		}
	}
	
	// Run the actual insertion/replacement
	if (placeholders == kOCSnippetsPlaceholderNone) {
		NSLog(@"Snippets.sugar: PLAIN TEXT");
		// Get our first selection
		NSRange selection = [[[[self actionContext] selectedRanges] objectAtIndex:0] rangeValue];
		CETextRecipe *recipe = [CETextRecipe textRecipe];
		[recipe addReplacementString:snippet forRange:selection];
		// Only apply the recipe if it's going to result in a change
		[recipe prepare];
		if ([recipe numberOfChanges] > 0) {
			[[self actionContext] applyTextRecipe:recipe];
		}
	} else {
		NSLog(@"Snippets.sugar: SNIPPET: %@", snippet);
		[[self actionContext] insertTextSnippet:[CETextSnippet snippetWithString:snippet]];
	}
}

- (void)dealloc
{
	[self setActionContext:nil];
	[super dealloc];
}

@end