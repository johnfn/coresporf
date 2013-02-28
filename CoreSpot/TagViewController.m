//
//  TagViewController.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/28/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "TagViewController.h"
#import "Photo+Flickr.h"
#import "Tag+Flickr.h"
#import "DocumentManager.h"
#import "ImageViewController.h"

@interface TagViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSArray* imagesWithTag;
@end

@implementation TagViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagesWithTag = @[];
    [[self activityIndicator] startAnimating];
    
    [DocumentManager withDocumentDo:^(UIManagedDocument* document){
        self.imagesWithTag = [Tag getPhotosFromTag:self.tag.name document:document];
        NSLog(@"%d", self.imagesWithTag.count);
        
        [[self activityIndicator] stopAnimating];
        [self.tableView reloadData];
        
        /* TODO...
        [document saveToURL:[self dataURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL
            NSLog(@"Saved, presumably.");
        }];
        */
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    int index = [self.tableView indexPathForSelectedRow].row;
    Photo *photo = [self.imagesWithTag objectAtIndex:index];
    NSString *url = photo.url;
    NSString *title = photo.title;
    
    ImageViewController *newController = (ImageViewController*)segue.destinationViewController;
    
    newController.imageURL = [NSURL URLWithString:url];
    newController.imageTitle = title;
    
    photo.lastAccessed = [NSDate date];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.imagesWithTag.count;
}

- (void)finishedLoading:(NSArray*)data {
    UITableViewCell *cell = data[0];
    UIImage *img = data[1];
    cell.imageView.image = img;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    int index = [indexPath row];
    Photo *p = [self.imagesWithTag objectAtIndex:index];
    
    cell.textLabel.text = p.title;
    cell.detailTextLabel.text = p.subtitle;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("image fetcher", NULL);
    dispatch_async(downloadQueue, ^{
        [self performSelectorOnMainThread:@selector(finishedLoading:)
                               withObject:@[cell, [p getThumbnail]]
                            waitUntilDone:YES];
    });
    
    return cell;
}

@end
