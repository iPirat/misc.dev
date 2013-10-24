//
//  RecentPhotoManager.m
//  SPoT
//
//  Created by Sergei Haller on 15.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import "RecentPhotoManager.h"
#import "FlickrFetcher.h"

#define USER_DEFAULTS_KEY_RECENT_PHOTOS @"com.shaller.SPoT.RecentPhotos"

@implementation RecentPhotoManager

// a photo is an NSDictionary
// we store all photos in a dictionary photoId->photo


+ (NSArray *)getAllRecentPhotos {
    NSDictionary *recentPhotos = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULTS_KEY_RECENT_PHOTOS];
    // sort by lastModDate before returning
    NSArray *sortedPhotos = [[recentPhotos allValues] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:FLICKR_LAST_ACCESS_DATE_BY_SPOT ascending:NO]]];
    return sortedPhotos;
}

+ (void)addRecentPhoto:(NSDictionary *)flickrPhoto {


    NSString *photoId = [flickrPhoto[FLICKR_PHOTO_ID] description];
    
    if (photoId){
        
        // get or create recentPhotos Store
        NSMutableDictionary *recentPhotos = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULTS_KEY_RECENT_PHOTOS] mutableCopy];
        if (!recentPhotos) recentPhotos = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        // set last access date of the photo to "now" and add it to the Store
        NSMutableDictionary *flickrPhotoMod = [flickrPhoto mutableCopy];
        flickrPhotoMod[FLICKR_LAST_ACCESS_DATE_BY_SPOT] = [[NSDate alloc] init];
        recentPhotos[photoId] = flickrPhotoMod;
        
        // store the Store
        [[NSUserDefaults standardUserDefaults] setObject:recentPhotos forKey:USER_DEFAULTS_KEY_RECENT_PHOTOS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
}



@end
