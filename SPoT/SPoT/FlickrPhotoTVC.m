//
//  FlickrPhotoTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "RecentPhotoManager.h"

@interface FlickrPhotoTVC() <UISplitViewControllerDelegate>
@end


@implementation FlickrPhotoTVC 

// sets the Model
// reloads the UITableView (since Model is changing)

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

#pragma mark - Segue

// prepares for the "Show Image" segue by seeing if the destination view controller of the segue
//  understands the method "setImageURL:"
// if it does, it sends setImageURL: to the destination view controller with
//  the URL of the photo that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the photo's title

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                NSDictionary *flickrPhoto = self.photos[indexPath.row];
                int photoFormat = [segue isKindOfClass:[UIStoryboardPopoverSegue class]]?FlickrPhotoFormatOriginal:FlickrPhotoFormatLarge;
                NSURL *url = [FlickrFetcher urlForPhoto:flickrPhoto format:photoFormat];
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                
                // store the photo in recent photos list
                [RecentPhotoManager addRecentPhoto:flickrPhoto];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

// lets the UITableView know how many rows it should display
// in this case, just the count of dictionaries in the Model's array

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

// a helper method that looks in the Model for the photo dictionary at the given row
//  and gets the title out of it

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description]; // description because could be NSNull
}

// a helper method that looks in the Model for the photo dictionary at the given row
//  and gets the title out of it

- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [self descriptionForRow:row];
}

// a helper method that looks in the Model for the photo dictionary at the given row
//  and gets the owner of the photo out of it

- (NSString *)ownerForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_OWNER] description]; // description because could be NSNull
}

// a helper method that looks in the Model for the photo dictionary at the given row
//  and gets the owner of the photo out of it

- (NSString *)descriptionForRow:(NSUInteger)row
{
    return [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description]; // description because could be NSNull
}

// loads up a table view cell with the title and owner of the photo at the given row in the Model

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}


#pragma mark - UISplitControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end
