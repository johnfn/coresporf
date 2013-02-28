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
#import "TagViewController.h"
#import "DocumentManager.h"

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
    
    [DocumentManager withDocumentURL:[self dataURL] do:^(UIManagedDocument* document){
        self.tags = [Tag getAllTags:document];
        
        [self.tableView reloadData];
        
        /* TODO...
        [document saveToURL:[self dataURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL
            NSLog(@"Saved, presumably.");
        }];
        */
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    int index = [self.tableView indexPathForSelectedRow].row;
    TagViewController *newController = (TagViewController*)segue.destinationViewController;
    
    newController.tag = [self.tags objectAtIndex:index];
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
