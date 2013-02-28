//
//  ImageViewController.m
//  Spot
//
//  Created by Grant Mathews on 2/12/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ImageViewController

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)finishedLoading:(UIImage*)img {
    [self.activityIndicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.imageView setImage:img];
    self.scrollView.contentSize = img.size;
    
    // Save image to cache.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"ImageViewDidLoad!");
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 2.0;
    
    [[self activityIndicator] startAnimating];
    [self activityIndicator].hidesWhenStopped = true;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("image fetcher", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *data;
        UIImage *img;
        NSLog(@"%@", self.imageURL);
        data = [NSData dataWithContentsOfURL:self.imageURL];
        //TODO cache data in CoreData
        
        img = [[UIImage alloc] initWithData:data];
        
        [self performSelectorOnMainThread:@selector(finishedLoading:)
                               withObject:img
                            waitUntilDone:YES];
    });
    
    [self.imageView bringSubviewToFront:self.activityIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
