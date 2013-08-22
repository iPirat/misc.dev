//
//  DisplayUrlVC.m
//  SPoT
//
//  Created by Sergei Haller on 21.08.13.
//  Copyright (c) 2013 Sergei Haller. All rights reserved.
//

#import "DisplayAttributedStringVC.h"

@interface DisplayAttributedStringVC ()
@property (weak, nonatomic) IBOutlet UITextView *attrTextView;
@end

@implementation DisplayAttributedStringVC

-(void)setAttrString:(NSAttributedString *)attrString {
    _attrString = attrString;
    [self.attrTextView setAttributedText:self.attrString];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    [self.attrTextView setAttributedText:self.attrString];
}

@end
