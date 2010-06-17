//
//  SASnippetsBridge.h
//  SnippetsClient
//
//  Created by Vadim Shpakovski on 15/06/2010.
//  Copyright 2010 Lucky Ants. All rights reserved.
//

// Snippets menubar icon can open the Search Panel or the Global Menu
typedef enum {
    kSASnippetsModeNone = 0,
    kSASnippetsModeGlobalMenu,
    kSASnippetsModeSearchPanel
} SASnippetsMode;

// This block gets called when user selects a snippet using the Search Panel or the Global Menu
typedef void (^SASnippetsHandler)(NSDictionary *selectedSnippet);

// The selected snippet is a dictionary with one key-value pair for the source code
extern NSString *const kSASnippetSourceCode;

// Snippets bridge is a singleton manager representing Snippets application
@interface SASnippetsBridge : NSObject {
    SASnippetsHandler _selectionHandler;
    NSString *_postbackNotificationName;
}

// First, you retrieve the instance of Snippets bridge by calling this method
+ (id)sharedBridge;

// Next, you make a request to Snippets using the following method
- (void)selectSnippetUsingMode:(SASnippetsMode)menubarMode handler:(SASnippetsHandler)selectionHandler;

@end
