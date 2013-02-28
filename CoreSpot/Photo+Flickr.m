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
    newPhoto.url = [[FlickrFetcher urlForPhoto:data format:FlickrPhotoFormatLarge] path];
    newPhoto.subtitle      = [descDict objectForKey:@"_content"];
    
    // For tags, grab the Tag object and add that to the set.
    
    NSString* tags = [data objectForKey:@"tags"];
    NSArray* split = [tags componentsSeparatedByString:@" "];
    
    for (NSString *s in split) {
        Tag *tag = [Tag getTagByName:s document:document];
        [newPhoto addTagObject:tag];
    }
    
    NSLog(@"Newly created photo lookz like dis %@", newPhoto);
    
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
