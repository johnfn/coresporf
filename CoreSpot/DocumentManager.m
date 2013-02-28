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

+ (NSURL*)dataURL {
    NSURL *cachePath = [DocumentManager rootCachePath];
    
    cachePath = [cachePath URLByAppendingPathComponent:@"photoData"];
    cachePath = [cachePath URLByAppendingPathExtension:@"dat"];
    
    return cachePath;
}

+ (NSURL*)rootCachePath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    return [paths objectAtIndex:0];
}

+ (void)withDocumentDo:(void(^)(UIManagedDocument*))block {
    static UIManagedDocument* document = nil;

    void (^completionHandler)(BOOL)= ^(BOOL success) {
        if (!success) {
            //TODO um, wat?
            NSLog(@"Uh oh, there was an error.");
        }
        
        block(document);
    };
    
    if (document == nil) {
        document = [[UIManagedDocument alloc] initWithFileURL:[DocumentManager dataURL]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[DocumentManager dataURL] path]]) {
            [document openWithCompletionHandler:completionHandler];
        } else {
            [document saveToURL:[DocumentManager dataURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:completionHandler];
        }
    } else {
        completionHandler(true);
    }
}

@end
