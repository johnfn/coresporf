//
//  SpotViewController.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/27/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "SpotViewController.h"

@interface SpotViewController ()

@end

@implementation SpotViewController

// TODO - move somewhere more apposite
- (NSURL*)dataURL {
    NSURL *cachePath = [self rootCachePath];
    
    cachePath = [cachePath URLByAppendingPathComponent:@"photoData"];
    cachePath = [cachePath URLByAppendingPathExtension:@"dat"];
    
    return cachePath;
}

- (NSURL*)rootCachePath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    return [paths objectAtIndex:0];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    void (^completionHandler)(BOOL)= ^(BOOL success) {
        if (!success) {
            NSLog(@"Uh oh, there was an error.");
        }
        NSLog(@"Successfully loaded the thingy!");
    };
    
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:[self dataURL]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self dataURL] path]]) {
        [document openWithCompletionHandler:completionHandler];
    } else {
        [document saveToURL:[self dataURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:completionHandler];
    }
    
    NSLog(@"Hello world!");
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
