//
//  Photo+Flickr.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/27/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "Photo+Flickr.h"

@implementation Photo (Flickr)
+ (Photo*)addPhoto:(UIManagedDocument *)document:(NSDictionary*)data {
    NSManagedObjectContext *context = document.managedObjectContext;
    Photo* newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    newPhoto.title = @"Herpderp";
    
    return newPhoto;
}

+ (NSArray*)getAllPhotos:(UIManagedDocument *)document {
    NSManagedObjectContext *context = document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSError *error;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    
    return photos;
}

@end
