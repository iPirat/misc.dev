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
@property (strong, nonatomic) NSMutableDictionary *tags;
@end

@implementation FlickrTagsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"All Tags"];
    [self addFlickrPhotos:[FlickrFetcher stanfordPhotos]];
}

- (void)addFlickrPhotos:(NSArray *)flickrPhotos {
    for (NSDictionary *flickrPhoto in flickrPhotos) {
        NSString *flickrTags = [self getFlickrTagsFrom:flickrPhoto];
        NSArray *tags = [flickrTags componentsSeparatedByString:@" "];
        for (NSString *tag in tags) {
            // skipping forbidden tags
            if (![[NSArray arrayWithObjects:@"portrait", @"landscape", @"cs193pspot", nil] containsObject:tag]){
                if (!self.tags[tag]) self.tags[tag] = [[NSMutableArray alloc] init];
                [self.tags[tag] addObject:flickrPhoto];
            }
        }
    }
}



#pragma mark - Property Business

- (NSMutableDictionary *)tags {
    if (!_tags) _tags = [[NSMutableDictionary alloc] init];
    return _tags;
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
    
    NSArray *allTags = [self.tags allKeys];
    [allTags sortedArrayUsingSelector:@selector(compare:)];
    
    NSString *tag = allTags[indexPath.row];

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
                    [segue.destinationViewController setTitle:[self displayTag:tag]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:)
                                                          withObject:self.tags[tag]];
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
