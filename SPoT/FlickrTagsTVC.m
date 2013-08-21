//
//  FlickrTagsTVC.m
//  SPoT
//
//  Created by Sergei Haller on 11.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import "FlickrTagsTVC.h"
#import "FlickrFetcher.h"

@interface FlickrTagsTVC ()
@property (strong, nonatomic) NSDictionary *tags;
@property (strong, nonatomic, readonly) NSArray *sortedTags;
@end

#define FORBIDDEN_TAGS [NSArray arrayWithObjects:@"portrait", @"landscape", @"cs193pspot", nil]

@implementation FlickrTagsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"All Tags"];
    [self.refreshControl addTarget:self
                            action:@selector(loadPhotosFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
    [self loadPhotosFromFlickr];
}

- (void)loadPhotosFromFlickr {
    [self.refreshControl beginRefreshing];
    
    dispatch_queue_t getStanfordPhotosQ = dispatch_queue_create("getStanfordPhotosQ", NULL);
    dispatch_async(getStanfordPhotosQ, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *flickrPhotos = [FlickrFetcher stanfordPhotos];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSMutableDictionary *preparedSelfTags = [self addFlickrPhotos:flickrPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tags = preparedSelfTags;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
    

}

- (NSMutableDictionary *)addFlickrPhotos:(NSArray *)flickrPhotos {
    NSMutableDictionary *preparedSelfTags = [[NSMutableDictionary alloc] init];
    for (NSDictionary *flickrPhoto in flickrPhotos) {
        NSString *flickrTags = [self getFlickrTagsFrom:flickrPhoto];
        NSArray *tags = [flickrTags componentsSeparatedByString:@" "];
        for (NSString *tag in tags) {
            // skipping forbidden tags
            if (![FORBIDDEN_TAGS containsObject:tag]){
                if (!preparedSelfTags[tag]) preparedSelfTags[tag] = [[NSMutableArray alloc] init];
                
                // add photo, keeping array sorted by title
                NSUInteger newIndex = [preparedSelfTags[tag] indexOfObject:flickrPhoto
                                                      inSortedRange:(NSRange){0, [preparedSelfTags[tag] count]}
                                                            options:NSBinarySearchingInsertionIndex
                                                    usingComparator:^NSComparisonResult(NSDictionary *p1, NSDictionary *p2) {
                                                        return [p1[FLICKR_PHOTO_TITLE] compare:p2[FLICKR_PHOTO_TITLE]];
                                                    }];
                [preparedSelfTags[tag] insertObject:flickrPhoto atIndex:newIndex];
            }
        }
    }
    return preparedSelfTags;
}


#pragma mark - Property Business

- (NSDictionary *)tags {
    if (!_tags) _tags = [[NSDictionary alloc] init];
    return _tags;
}

- (NSArray *)sortedTags {
    return [[self.tags allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *tag = self.sortedTags[indexPath.row];

    // Configure the cell...
    cell.textLabel.text = [self displayTag:tag];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d entries", [self.tags[tag] count] ];
    
    return cell;
}


#pragma mark - Segue

// prepares for the "Show Image" segue by seeing if the destination view controller of the segue
//  understands the method "setImageURL:"
// if it does, it sends setImageURL: to the destination view controller with
//  the URL of the photo that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the photo's title

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image Table"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSString *tag = [sender.textLabel.text lowercaseString];
                    NSArray *photos = self.tags[tag];
                    [segue.destinationViewController setTitle:[self displayTag:tag]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:)
                                                          withObject:photos];
                }
            }
        }
    }
}

#pragma mark - Helper

- (NSString *)displayTag:(NSString *)tag{
    return [tag capitalizedString];
}

- (NSString *)getFlickrTagsFrom:(NSDictionary *)flickrPhoto
{
    return [flickrPhoto[FLICKR_TAGS] description]; // description because could be NSNull
}

@end
