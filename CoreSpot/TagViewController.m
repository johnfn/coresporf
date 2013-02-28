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
        NSLog(@"Umm");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagesWithTag = @[];
    [[self activityIndicator] startAnimating];
    
    [DocumentManager withDocumentDo:^(UIManagedDocument* document){
        NSLog(@"Loaded.");
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    int index = [indexPath row];
    Photo *p = [self.imagesWithTag objectAtIndex:index];
    
    cell.textLabel.text = p.title;
    cell.detailTextLabel.text = p.subtitle;
    
    return cell;
}

@end
