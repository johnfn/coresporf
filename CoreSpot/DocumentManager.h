//
//  DocumentManager.h
//  CoreSpot
//
//  Created by Grant Mathews on 2/28/13.
//  Copyright (c) 2013 johnfn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentManager : NSObject
+ (void)withDocumentURL:(NSURL*)url do:(void(^)(UIManagedDocument*))block;
@end
