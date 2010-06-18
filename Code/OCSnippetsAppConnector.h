//
//  OCSnippetsAppConnector.h
//  Snippets-sugar
//
//  Created by Ian Beck on 6/15/10.
//  Copyright 2010 One Crayon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OCSnippetsAppBaseAction.h"


@interface OCSnippetsAppConnector : OCSnippetsAppBaseAction {
	id actionContext;
}

@property (readwrite,retain) id actionContext;

- (void)snippetInsertCallback:(NSString *)snippet;

@end
