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

- (NSURL*)rootCachePath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    return [paths objectAtIndex:0];
}

#define CACHE_SIZE 5

- (void)checkForCacheEviction {
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self rootCachePath] includingPropertiesForKeys:@[NSFileModificationDate] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    NSURL *oldestFile = nil;
    NSDate *oldestDate = nil;
    int numFilesCached = 0;
    
    for (NSURL *filePath in directoryContent) {
        if ([filePath.absoluteString hasSuffix:@"/"]) {
            continue;
        }
        
        ++numFilesCached;
    }
    
    if (numFilesCached <= CACHE_SIZE) return;
    
    for (NSURL *filePath in directoryContent) {
        // skip directories.
        if ([filePath.absoluteString hasSuffix:@"/"]) {
            continue;
        }
        
        NSDate *fileDate = nil;
        [filePath getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:NULL];
        
        if (oldestDate == nil || [oldestDate compare:fileDate] == NSOrderedDescending) {
            oldestDate = fileDate;
            oldestFile = filePath;
        }
    }
    
    NSLog(@"%@", oldestFile);
    
    [[NSFileManager defaultManager] removeItemAtURL:oldestFile error:nil];
}

- (NSURL*)cachePath {
    NSURL *cachePath = [self rootCachePath];
    
    cachePath = [cachePath URLByAppendingPathComponent:self.imageTitle];
    cachePath = [cachePath URLByAppendingPathExtension:@"png"];
    
    [self checkForCacheEviction];
    
    return cachePath;
}

- (void)finishedLoading:(UIImage*)img {
    [self.activityIndicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.imageView setImage:img];
    self.scrollView.contentSize = img.size;
    
    // Save image to cache.
    
    [UIImagePNGRepresentation(img) writeToURL:[self cachePath] atomically:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 2.0;
    
    [[self activityIndicator] startAnimating];
    [self activityIndicator].hidesWhenStopped = true;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("image fetcher", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *data;
        UIImage *img;
        NSError *err;
        // The idea to check for file existence in this way thanks to StackOverflow:
        // http://stackoverflow.com/questions/1927754/testing-file-existence-using-nsurl
        if ([[self cachePath] checkResourceIsReachableAndReturnError:&err] == NO) {
            data = [NSData dataWithContentsOfURL:self.imageURL];
        } else {
            data = [NSData dataWithContentsOfURL:[self cachePath]];
        }
        
        //[[self cachePath] get]
        
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
