//
//  Photo+Flickr.h
//  CoreSpot
//
//  Created by Grant Mathews on 2/27/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)
+ (Photo*)addPhoto:(UIManagedDocument *)document data:(NSDictionary*)data;
+ (NSArray*)getAllPhotos:(UIManagedDocument *)document;
@end
