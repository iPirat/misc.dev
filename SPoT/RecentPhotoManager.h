//
//  RecentPhotoManager.h
//  SPoT
//
//  Created by Sergei Haller on 15.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotoManager : NSObject

+ (NSArray *)getAllRecentPhotos;

+ (void)addRecentPhoto:(NSDictionary *)flickrPhoto;

@end

#define FLICKR_LAST_ACCESS_DATE_BY_SPOT @"FLICKR_LAST_ACCESS_DATE_BY_SPOT"
