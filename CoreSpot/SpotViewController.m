//
//  SpotViewController.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/27/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "SpotViewController.h"
#import "Photo+Flickr.h"
#import "Tag+Flickr.h"

@interface SpotViewController ()
@property (atomic) NSArray* tags;
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
    self.tags = @[];
    
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:[self dataURL]];
    void (^completionHandler)(BOOL)= ^(BOOL success) {
        if (!success) {
            //TODO um, wat?
            NSLog(@"Uh oh, there was an error.");
        }
        NSLog(@"Successfully loaded the thingy!");
        
        self.tags = [Tag getAllTags:document];
        
        [self.tableView reloadData];
        
        /*
         //TODO..mebbe
        [document saveToURL:[self dataURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            NSLog(@"Saved, presumably.");
        }];
         */
    };
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self dataURL] path]]) {
        [document openWithCompletionHandler:completionHandler];
    } else {
        [document saveToURL:[self dataURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:completionHandler];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    int index = [indexPath row];
    Tag *tag = [self.tags objectAtIndex:index];
    
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", tag.photos.count];
    
    return cell;
}


@end
