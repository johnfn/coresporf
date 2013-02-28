//
//  Tag+Flickr.m
//  CoreSpot
//
//  Created by Grant Mathews on 2/28/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import "Tag+Flickr.h"
#import "Photo+Flickr.h"

@implementation Tag (Flickr)

+ (Tag*)addTag:(UIManagedDocument *)document name:(NSString*)name {
    NSManagedObjectContext *context = document.managedObjectContext;
    Tag* newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
    
    newTag.name = [name capitalizedString];
    
    return newTag;
}

+ (NSArray *)getAllTags:(UIManagedDocument *)document {
    NSManagedObjectContext *context = document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    [request setReturnsObjectsAsFaults:NO];
    NSError *error;
    NSArray *tags = [context executeFetchRequest:request error:&error];
    
    if (tags.count > 0) {
        return tags;
    }
    
    // Force photo to load in all tags.
    [Photo getAllPhotos:document];
    tags = [context executeFetchRequest:request error:&error];
    
    return tags;
}

+ (NSArray*)getPhotosFromTag:(NSString*)name document:(UIManagedDocument*)document {
    Tag* tag = [Tag getTagByName:name document:document];
    
    return [tag.photos allObjects];
}

+ (NSArray*)getAllTagsAsStringArray:(UIManagedDocument*)document {
    NSArray* allTagObjects = [Tag getAllTags:document];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    for (Tag* tag in allTagObjects) {
        [result addObject:tag.name];
    }
    
    return result;
}

+ (Tag*)getTagByName:(NSString*)name document:(UIManagedDocument*)document {
    name = [name capitalizedString];
    NSManagedObjectContext *context = document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSArray *tag = [context executeFetchRequest:request error:NULL];
    
    if (tag.count == 0) {
        return [Tag addTag:document name:name];
    } else if (tag.count > 1) {
        NSLog(@"Was looking for the unique tag with name %@, but found many tags. Um.", name);
    }
    
    return tag[0];
}


@end
