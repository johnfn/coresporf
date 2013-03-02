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
@property (strong, nonatomic) NSMutableString* headings;
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

- (void)finishedLoading {
    [[self activityIndicator] stopAnimating];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headings = [[NSMutableString alloc] init];
    self.imagesWithTag = @[];
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidesWhenStopped = true;
    self.navigationBar.title = self.tag.name;
    
    [DocumentManager withDocumentDo:^(UIManagedDocument* document){
        self.imagesWithTag = [Tag getPhotosFromTag:self.tag.name document:document];
        
        // Sort by heading.
        self.imagesWithTag = [self.imagesWithTag sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
            Photo* photoA = (Photo*)a;
            Photo* photoB = (Photo*)b;
            
            return [photoA.sectionHeading compare:photoB.sectionHeading];
        }];
        
        for (Photo* p in self.imagesWithTag) {
            if ([self.headings rangeOfString:p.sectionHeading].location == NSNotFound) {
                [self.headings appendString:p.sectionHeading];
            }
        }
        
        [self performSelectorOnMainThread:@selector(finishedLoading)
                               withObject:NULL
                            waitUntilDone:YES];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    int index = [self.tableView indexPathForSelectedRow].row;
    int section = [self.tableView indexPathForSelectedRow].section;
    Photo *photo = [self getCorrespondingPhoto:index section:section];
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
    NSMutableSet* seenSections = [[NSMutableSet alloc] init];
    
    for (Photo *p in self.imagesWithTag) {
        [seenSections addObject:p.sectionHeading];
    }
    
    // Return the number of sections.
    return seenSections.count;
}

- (NSString*)sectionToString:(int)section {
    return [self.headings substringWithRange:NSMakeRange(section, 1)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* sectionString = [self sectionToString:section];
    int count = 0;
    
    for (Photo *p in self.imagesWithTag) {
        if ([p.sectionHeading isEqualToString:sectionString]) {
            ++count;
        }
    }
    
    return count;
}

- (void)finishedLoading:(NSArray*)data {
    UITableViewCell *cell = data[0];
    UIImage *img = data[1];
    cell.imageView.image = img;
    
    [self.tableView reloadData];
}

- (Photo*)getCorrespondingPhoto:(int)index section:(int)section {
    NSString* sectionChar = [self sectionToString:section];
    Photo *p;
    
    for (p in self.imagesWithTag) {
        if ([p.sectionHeading isEqualToString:sectionChar]) {
            if (index == 0) {
                break;
            }
            --index;
        }
    }
    
    return p;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    int index = [indexPath row];
    int section = [indexPath section];
    
    Photo *p = [self getCorrespondingPhoto:index section:section];
    
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
