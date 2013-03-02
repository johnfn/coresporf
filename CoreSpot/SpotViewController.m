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
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation SpotViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityIndicator.hidesWhenStopped = true;
    
    self.tags = @[];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadTagList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self updateTagDisplay:false];
}

- (void)reloadTagList {
    [self updateTagDisplay:true];
}

- (void)updateTagDisplay:(bool)shouldReload {
    [DocumentManager withDocumentDo:^(UIManagedDocument* document){
        if (shouldReload) {
            dispatch_queue_t downloadQueue = dispatch_queue_create("load taglist", NULL);
            dispatch_async(downloadQueue, ^{
                [Tag reload:document];
                // We need to wait until this thread finishes before we can
                // update the delay, so we recursively call updateTagDisplay
                // once that happens.
                // We're setting shouldReload to false, so the recursive stack
                // will only ever get 1-deep.
                [self performSelectorOnMainThread:@selector(updateTagDisplay:)
                                       withObject:false
                                    waitUntilDone:YES];
            });
            
            return;
        }
        
        NSArray* allTags = [Tag getAllTags:document];
        NSMutableArray* tagsWeWant = [[NSMutableArray alloc] init];
        
        // Filter out the tags we don't want.
        for (Tag* tag in allTags) {
            NSString* tagName = [tag.name lowercaseString];
            
            if ([tagName isEqualToString:@"portrait"]  ||
                [tagName isEqualToString:@"landscape"] ||
                [tagName isEqualToString:@"cs193pspot"]) continue;
            
            [tagsWeWant addObject:tag];
        }
        
        self.tags = tagsWeWant;
        
        [self.tableView reloadData];
    }];
    
    if (!shouldReload) {
        [self.refreshControl endRefreshing];
        [self.activityIndicator stopAnimating];
    }
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
    
    NSLog(@"loaded new: %@", newController);
    
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
