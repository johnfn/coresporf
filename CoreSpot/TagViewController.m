//
//  TagViewController.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/28/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "TagViewController.h"
#import "Photo+Flickr.h"

@interface TagViewController ()
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