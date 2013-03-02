//
//  Photo.h
//  CoreSpot
//
//  Created by Grant Mathews on 3/1/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * lastAccessed;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * sectionHeading;
@property (nonatomic, retain) NSSet *tag;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagObject:(Tag *)value;
- (void)removeTagObject:(Tag *)value;
- (void)addTag:(NSSet *)values;
- (void)removeTag:(NSSet *)values;

@end
