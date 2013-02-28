//
//  DocumentManager.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/28/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "DocumentManager.h"

@interface DocumentManager()
@end

@implementation DocumentManager

+ (void)withDocumentURL:(NSURL*)url do:(void(^)(UIManagedDocument*))block {
    static UIManagedDocument* document = nil;

    void (^completionHandler)(BOOL)= ^(BOOL success) {
        if (!success) {
            //TODO um, wat?
            NSLog(@"Uh oh, there was an error.");
        }
        
        block(document);
    };
    
    if (document == nil) {
        document = [[UIManagedDocument alloc] initWithFileURL:url];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            [document openWithCompletionHandler:completionHandler];
        } else {
            [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:completionHandler];
        }
    } else {
        completionHandler(true);
    }
}

@end
