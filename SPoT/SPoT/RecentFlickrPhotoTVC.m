//
//  RecentFlickrPhotoTVC.m
//  SPoT
//
//  Created by Sergei Haller on 15.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import "RecentFlickrPhotoTVC.h"
#import "RecentPhotoManager.h"

@interface RecentFlickrPhotoTVC ()

@end

@implementation RecentFlickrPhotoTVC

// purpose of this entire VC is just to set its Model by getting from UserData

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.photos = [RecentPhotoManager getAllRecentPhotos];
}


- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_LAST_ACCESS_DATE_BY_SPOT] description]; 
}
@end
