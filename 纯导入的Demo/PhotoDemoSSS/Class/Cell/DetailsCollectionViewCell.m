//
//  DetailsCollectionViewCell.m
//  PhotoDemoSSS
//
//  Created by sks on 16/9/27.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import "DetailsCollectionViewCell.h"
#import "customHeader.h"


@implementation DetailsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _markImageHeight20.constant = 20 * ScaleSize;
    _markImageWidth20.constant = 20 * ScaleSize;
    
    if ([UserData userDataStandard].markImageName != nil) {
        _markImageView.image = [UIImage imageNamed:[UserData userDataStandard].markImageName];
    }
}

@end
