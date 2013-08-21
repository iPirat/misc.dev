//
//  DisplayUrlVC.m
//  SPoT
//
//  Created by Sergei Haller on 21.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import "DisplayUrlVC.h"

@interface DisplayUrlVC ()
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;
@end

@implementation DisplayUrlVC

-(void)setUrl:(NSURL *)url{
    _url = url;
    [self.urlTextView setText:[self.url description]];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    [self.urlTextView setText:[self.url description]];
}

@end
