//
//  OCSnippetsAppNewSnippet.m
//  Snippets-sugar
//
//  Created by Ian Beck on 6/18/10.
//  Copyright 2010 One Crayon. All rights reserved.
//

#import "OCSnippetsAppNewSnippet.h"
#import <EspressoTextActions.h>
#import <EspressoTextCore.h>

// Logical enum for checking preference values
typedef enum {
    kOCSnippetsLicenseNone = 0,
    kOCSnippetsLicenseApache2 = 1,
	kOCSnippetsLicenseBSD = 2,
	kOCSnippetsLicenseFreeBSD = 3,
	kOCSnippetsLicenseGPL = 4,
	kOCSnippetsLicenseGPLv3 = 5,
	kOCSnippetsLicenseMIT = 6
} OCSnippetsLicense;

@implementation OCSnippetsAppNewSnippet

- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
	self = [super init];
	if (self == nil)
		return nil;
	
	return self;
}

- (BOOL)canPerformActionWithContext:(id)context
{
	// Only allowed if we have a selection
	return [[[context selectedRanges] objectAtIndex:0] rangeValue].length > 0;
}

- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
	// Grab our default settings
	NSString *selection = [[context string] substringWithRange:[[[context selectedRanges] objectAtIndex:0] rangeValue]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *author = [defaults stringForKey:@"SnippetsAppDefaultAuthor"];
	OCSnippetsLicense license = [defaults integerForKey:@"SnippetsAppDefaultLicense"];
	
	// Create our basic addition URL using the current selection
	NSMutableString *url = [NSMutableString stringWithFormat:@"snippet:add?code=%@", [selection stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	// Add the author, if one exists
	if (![author isEqualToString:@""]) {
		[url appendFormat:@"&author=%@", [author stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
	
	// Add the license, if one exists
	if (license != kOCSnippetsLicenseNone) {
		[url appendString:@"&license="];
		if (license == kOCSnippetsLicenseApache2) {
			[url appendString:@"apache2"];
		} else if (license == kOCSnippetsLicenseBSD) {
			[url appendString:@"bsd"];
		} else if (license == kOCSnippetsLicenseFreeBSD) {
			[url appendString:@"freebsd"];
		} else if (license == kOCSnippetsLicenseGPL) {
			[url appendString:@"gpl"];
		} else if (license == kOCSnippetsLicenseGPLv3) {
			[url appendString:@"gplv3"];
		} else if (license == kOCSnippetsLicenseMIT) {
			[url appendString:@"mit"];
		}
	}
	
	// TODO: figure out the highlighting of the file
	
	return [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void)dealloc
{
	[super dealloc];
}

@end
