//
//  Tag+Flickr.h
//  CoreSpot
//
//  Created by Grant Mathews on 2/28/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "Tag.h"

@interface Tag (Flickr)

+ (NSArray*)getAllTags:(UIManagedDocument *)document;
+ (NSArray*)getAllTagsAsStringArray:(UIManagedDocument*)document;
+ (Tag*)getTagByName:(NSString*)name document:(UIManagedDocument*)document;
+ (NSArray*)getPhotosFromTag:(NSString*)name document:(UIManagedDocument*)document;
+ (void)reload:(UIManagedDocument*)document;

@end
