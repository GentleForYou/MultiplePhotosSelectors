//
//  DetailsViewController.h
//  PhotoDemoSSS
//
//  Created by sks on 16/9/27.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSInteger number;//第几个相册
@property (nonatomic, strong) NSArray *assetArray;
@end
