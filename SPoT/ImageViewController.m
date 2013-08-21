//
//  ImageViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"
#import "DisplayUrlVC.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) BOOL doAutoZoom;
@property (nonatomic, strong) UIPopoverController *urlPopoverController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarItem;
@end

@implementation ImageViewController

// resets the image whenever the URL changes

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

-(void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self.titleBarItem setTitle:title];
}

// fetches the data from the URL
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        NSURL *imageURL = self.imageURL; // to be kept in the block
        
        NSLog(@"resetImage: self=%@ imageURL=%@", self, imageURL, nil);

        [self.spinner startAnimating];
        
        dispatch_queue_t imageLoaderQ = dispatch_queue_create("imageLoaderQ", NULL);
        dispatch_async(imageLoaderQ, ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image ) {
                    self.scrollView.zoomScale = 1.0;
                    self.scrollView.contentSize = image.size;
                    self.imageView.image = image;
                    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    self.doAutoZoom = YES;
                    [self autocomputeZoomFactor];
                }
                [self.spinner stopAnimating];
            });
        });
        
        
    }
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

// returns the view which will be zoomed when the user pinches
// in this case, it is the image view, obviously
// (there are no other subviews of the scroll view in its content area)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

// add the image view to the scroll view's content area
// setup zooming by setting min and max zoom scale
//   and setting self to be the scroll view's delegate
// resets the image in case URL was set before outlets (e.g. scroll view) were set

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self autocomputeZoomFactor];
}

- (void)autocomputeZoomFactor {
    if (self.doAutoZoom){
        CGFloat xScale = self.scrollView.bounds.size.width  / self.imageView.image.size.width;
        CGFloat yScale = self.scrollView.bounds.size.height / self.imageView.image.size.height;
        
        self.scrollView.zoomScale = fmaxf(xScale, yScale);
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    self.doAutoZoom = NO;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([@"show url" isEqualToString: identifier]){
        return self.imageURL != nil && !self.urlPopoverController.isPopoverVisible;
    } 
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DisplayUrlVC class]]) {
        DisplayUrlVC *displayUrlVC = segue.destinationViewController;
        displayUrlVC.url = self.imageURL;
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            self.urlPopoverController = ((UIStoryboardPopoverSegue*)segue).popoverController;
        }
    }
}


@end
