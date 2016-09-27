//
//  DetailsViewController.m
//  PhotoDemoSSS
//
//  Created by sks on 16/9/27.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailsCollectionViewCell.h"
#import <Photos/Photos.h>

@interface DetailsViewController ()

@property (nonatomic, strong) NSMutableArray *imageArray;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"选择照片";
    _imageArray = [NSMutableArray array];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"DetailsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DetailsCollectionViewCell"];
    
    if (_assetArray.count > 0) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
          [self getImageData];
        }];
        [operation start];
    } else {
        NSLog(@"该相册中没有照片");
    }
}

- (void)getImageData
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.resizeMode = PHImageRequestOptionsDeliveryModeFastFormat;
    // 同步获得图片, 只会返回1张图片
//    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = NO;
    //CGSizeMake(180, 180)

    for (PHAsset *asset in _assetArray) {
        //PHImageManagerMaximumSize
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
                [_imageArray addObject:result];
            if ([asset isEqual:_assetArray.lastObject]) {
                [_collectionView reloadData];
            }
            }];
    }
    
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DetailsCollectionViewCell" forIndexPath:indexPath];
    if (_imageArray.count > 0 && _imageArray.count == _assetArray.count) {
        cell.cousomImageView.image = _imageArray[indexPath.row];
    }
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(80, 80);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
