//
//  SeleceAlbumViewController.h
//  PhotoDemoSSS
//
//  Created by sks on 16/9/27.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeleceAlbumViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;
@end
