//
//  OCSnippetsAppConnector.h
//  Snippets-sugar
//
//  Created by Ian Beck on 6/15/10.
//  Copyright 2010 One Crayon. All rights reserved.
//

/*
 This class handles sending the user to Snippets to select a snippet, and then parsing and inserting it into Espresso
*/

#import <Cocoa/Cocoa.h>
#import "OCSnippetsAppBaseAction.h"


@interface OCSnippetsAppConnector : OCSnippetsAppBaseAction {
	id actionContext;
}

@property (readwrite,retain) id actionContext;

- (void)snippetInsertCallback:(NSString *)snippet;

@end
