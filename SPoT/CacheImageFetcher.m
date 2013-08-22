//
//  CacheManager.m
//  SPoT
//
//  Created by Sergei Haller on 22.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import "CacheImageFetcher.h"
#import "FlickrFetcher.h"

#define CACHE_SIZE_NR_FILES 5

@implementation CacheImageFetcher

+ (NSData *)getImageFromURL:(NSURL*)imageURL{
    if (imageURL == nil) return nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *localURL = [[self class] getLocalURLfromRemoteURL:imageURL usingFileManager:fileManager];
    
    NSData *imageData = nil;
    if ([localURL checkResourceIsReachableAndReturnError:nil]) {
        // already cached -- grab cached data
        imageData = [[NSData alloc] initWithContentsOfURL:localURL];
    } else {
        // grab from net
        [FlickrFetcher enableNetworkActivity];
        imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        [FlickrFetcher disableNetworkActivity];
        
        // store to cache in a separate Q
        dispatch_queue_t storeToCacheQ = dispatch_queue_create("storeToCacheQ", NULL);
        dispatch_async(storeToCacheQ, ^{
            // store to cache
            [imageData writeToURL:localURL atomically:YES];
            // clean up too old files
            [[self class] cleanUpOldCacheUsingFileManager:fileManager];
        });
        
    }
    return imageData;
}

// takes the last component of the remote URL and appends to the cacheDir URL
+ (NSURL*)getLocalURLfromRemoteURL:(NSURL*)remoteURL usingFileManager:(NSFileManager *)fileManager {
    return [[[self class] cacheDirURLusingFileManager:fileManager] URLByAppendingPathComponent:[remoteURL lastPathComponent]];
}

+ (NSURL *)cacheDirURLusingFileManager:(NSFileManager *)fileManager{
    NSURL *docsDir = [fileManager URLForDirectory:NSDocumentDirectory
                                         inDomain:NSUserDomainMask
                                appropriateForURL:nil
                                           create:YES
                                            error:nil];
    NSURL *cacheDirURL = [docsDir URLByAppendingPathComponent:@"SPoT.Cache"];
    [fileManager createDirectoryAtURL:cacheDirURL withIntermediateDirectories:YES attributes:nil error:nil];
    return cacheDirURL;
}

+ (void)cleanUpOldCacheUsingFileManager:(NSFileManager *)fileManager {
    NSArray *properties = [NSArray arrayWithObjects:NSURLContentAccessDateKey, nil];
    
    NSArray *array = [fileManager
                      contentsOfDirectoryAtURL:[[self class] cacheDirURLusingFileManager:fileManager]
                      includingPropertiesForKeys:properties
                      options:(NSDirectoryEnumerationSkipsHiddenFiles)
                      error:nil];

    if (array.count > CACHE_SIZE_NR_FILES) {
        // newest at the beginning 
        NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
            return [        [[url2 resourceValuesForKeys:properties error:nil] valueForKey:NSURLContentAccessDateKey]
                    compare:[[url1 resourceValuesForKeys:properties error:nil] valueForKey:NSURLContentAccessDateKey]];
        }];
        for (int i = CACHE_SIZE_NR_FILES; i<sortedArray.count; i++) {
            NSURL *url = sortedArray[i];
            [fileManager removeItemAtURL:url error:nil];
        }
    }
    
}

@end
