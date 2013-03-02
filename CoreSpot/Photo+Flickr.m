//
//  Photo+Flickr.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/27/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Tag+Flickr.h"
#import "FlickrFetcher.h"

@implementation Photo (Flickr)

- (UIImage*)getThumbnail {
    if (self.thumbnail == nil) {
        self.thumbnail = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.thumbnailUrl]];
    }
    
    return [[UIImage alloc]initWithData:self.thumbnail];
}

+ (NSArray*)allPictures {
    static NSArray* pictures = nil;
    
    if (pictures == nil) {
        pictures = [FlickrFetcher stanfordPhotos];
    }
    
    return pictures;
}

+ (Photo*)addPhoto:(UIManagedDocument *)document data:(NSDictionary*)data {
    NSManagedObjectContext *context = document.managedObjectContext;
    Photo* newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    NSDictionary *descDict = [data objectForKey:@"description"];
    
    newPhoto.title = [data objectForKey:@"title"];
    newPhoto.url = [[FlickrFetcher urlForPhoto:data format:FlickrPhotoFormatLarge] absoluteString];
    newPhoto.thumbnailUrl = [[FlickrFetcher urlForPhoto:data format:FlickrPhotoFormatSquare] absoluteString];
    newPhoto.subtitle      = [descDict objectForKey:@"_content"];
    newPhoto.lastAccessed  = nil;
    
    // For tags, grab the Tag object and add that to the set.
    
    NSString* tags = [data objectForKey:@"tags"];
    NSArray* split = [tags componentsSeparatedByString:@" "];
    
    for (NSString *s in split) {
        Tag *tag = [Tag getTagByName:s document:document];
        [newPhoto addTagObject:tag];
    }
    
    return newPhoto;
}

+ (NSArray*)getAllPhotos:(UIManagedDocument *)document {
    NSManagedObjectContext *context = document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    [request setReturnsObjectsAsFaults:NO];
    NSError *error;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    
    if (photos.count > 0) {
        return photos;
    } else {
        [Photo reloadPhotos:document];
        return [context executeFetchRequest:request error:&error];
    }
}

+ (NSArray*)getRecentPhotos:(UIManagedDocument*)document {
    NSArray *allPhotos = [Photo getAllPhotos:document];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastAccessed" ascending:NO];
    NSArray *sortedArray = [allPhotos sortedArrayUsingDescriptors:@[descriptor]];
    NSArray *first10 = [sortedArray subarrayWithRange:NSMakeRange(0, 10)];
    
    // Exclude results with nil lastAccessed. They have never been accessed.
    
    NSMutableArray *noNils = [[NSMutableArray alloc] init];
    
    for (Photo* p in first10) {
        if (p.lastAccessed == nil) continue;
        [noNils addObject:p];
    }
    
    return noNils;
}

+ (void)reloadPhotos:(UIManagedDocument *)document {
    NSManagedObjectContext *context = document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSArray *photos = [context executeFetchRequest:request error:NULL];
    
    // Remove all photos that exist
    for (Photo *p in photos) {
        [document.managedObjectContext deleteObject:p];
    }
    
    // Now, add all photos.
    for (NSDictionary *dict in [Photo allPictures]) {
        [Photo addPhoto:document data:dict];
    }
}

@end
