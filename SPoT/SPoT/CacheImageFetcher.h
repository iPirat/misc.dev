//
//  CacheManager.h
//  SPoT
//
//  Created by Sergei Haller on 22.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheImageFetcher : NSObject

+ (NSData *)getImageFromURL:(NSURL*)imageURL;

@end
