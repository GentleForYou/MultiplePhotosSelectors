//
//  DetailsCollectionViewCell.h
//  PhotoDemoSSS
//
//  Created by sks on 16/9/27.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cousomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markImageHeight20;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markImageWidth20;


@end
