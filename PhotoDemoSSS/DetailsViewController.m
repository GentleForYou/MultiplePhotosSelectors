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
#import "UserData.h"

@interface DetailsViewController ()

@property (nonatomic, strong) NSMutableArray *imageArray;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageArray = [NSMutableArray array];
    
    self.navigationItem.title = @"选择照片";
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"2"] style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightButton)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    

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
    // 同步获得图片, 只会返回1张图片
//    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = NO;
    //CGSizeMake(180, 180)

    BOOL firstFlag = YES;
    
    if ([[UserData userDataStandard].isSeleceArray[_number] count] == 0) {
        firstFlag = YES;
    } else {
        firstFlag = NO;
    }
    for (PHAsset *asset in _assetArray) {
        if (firstFlag) {
            //先设置为全部未选中
            [[UserData userDataStandard].isSeleceArray[_number] addObject:[NSNumber numberWithBool:NO]];
        }
        //PHImageManagerMaximumSize
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
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
        
        if ([[UserData userDataStandard].isSeleceArray[_number][indexPath.row] boolValue]) {//被选中
            cell.markImageView.hidden = NO;
        } else {
            cell.markImageView.hidden = YES;
        }
    }
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 80);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    if ([[UserData userDataStandard].isSeleceArray[_number][indexPath.row] boolValue]) {//被选中
        [[UserData userDataStandard].isSeleceArray[_number] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        
            [[UserData userDataStandard].photoAssets removeObject:_assetArray[indexPath.row]];
        
        
    } else {
        
        if ([[UserData userDataStandard].photoAssets count] < [UserData userDataStandard].photoNumber) {
            
            [[UserData userDataStandard].isSeleceArray[_number] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
            [[UserData userDataStandard].photoAssets addObject:_assetArray[indexPath.row]];
        } else {
            UIAlertController *alVC = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"不能超过最大照片选择的张数" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alVC addAction:okAction];
            [self presentViewController:alVC animated:YES completion:nil];
        }
        
        
    }
    
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
}

- (void)leftButton
{
    [self.navigationController popViewControllerAnimated:YES];
}
//完成
- (void)rightButton
{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //通知发送数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoAssets" object:nil userInfo:@{@"assetsArray":[UserData userDataStandard].photoAssets}];

    }];
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
