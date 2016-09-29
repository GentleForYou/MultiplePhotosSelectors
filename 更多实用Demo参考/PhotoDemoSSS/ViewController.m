//
//  ViewController.m
//  PhotoDemoSSS
//
//  Created by sks on 16/9/23.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import "ViewController.h"

#import "customHeader.h"

static NSInteger maxNumber = 6;//能选择的最大照片数量(包括拍照和相册选择的)

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImageView *imageView;
}
@property (nonatomic, strong) NSMutableArray *dataArray;//首页图片数据数组

@property (nonatomic, strong) NSMutableArray *titleAndAssetsArray;//下个tableview的标题和图片资源
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    _titleAndAssetsArray = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAssetsData:) name:@"PhotoAssets" object:nil];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Width_Screen, Height_Screen)];
    imageView.backgroundColor = [UIColor blackColor];
    [self.navigationController.view addSubview:imageView];
    imageView.hidden = YES;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [imageView addGestureRecognizer:tap];
    

    [_collectionView registerNib:[UINib nibWithNibName:@"DetailsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DetailsCollectionViewCell"];
    
}

//点击按钮,选择图片
- (IBAction)button:(id)sender {
    
        __weak ViewController *weakSelf = self;
    
        //可以选择几张照片(拍照+选图的总数)
        if (_dataArray.count < maxNumber) {
            [UserData userDataStandard].photoNumber = maxNumber - _dataArray.count;
            
            UIAlertController *albumalertController = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            __block  NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {//从相册选择
                PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                if (status == PHAuthorizationStatusDenied) {//用户拒绝访问
                    UIAlertController *settingalertController = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"您的相册权限尚未开启,是否前去设置-隐私-照片中开启相册权限?" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {//去设置相册权限
                        NSURL *url = [NSURL URLWithString:@"prefs:root=Privacy&path=Photos"];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {     [[UIApplication sharedApplication] openURL:url];
                        }
                    }];
                    [settingalertController addAction:cancelAction];
                    [settingalertController addAction:okAction];
                    [weakSelf presentViewController:settingalertController animated:YES completion:nil];
                } else  if (status == PHAuthorizationStatusAuthorized) {//允许访问相册
                    // 获得所有的自定义相簿
                    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                    // 遍历所有的自定义相簿
                    if (assetCollections.count > 0) {
                        for (PHAssetCollection *assetCollection in assetCollections) {
                            PHFetchResult<PHAsset *> *assets1 = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                            NSDictionary *dic = @{@"title":assetCollection.localizedTitle,@"assets":assets1,@"count":[NSString stringWithFormat:@"%ld",assets1.count]};
                            [_titleAndAssetsArray addObject:dic];
                        }

                    }
                    // 获得相机胶卷,  estimatedAssetCount这个属性,在自定义相册里面返回的照片数是正确的,在相机胶圈中,返回的是不正确的
                    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
                    // 获得某个相簿中的所有PHAsset对象
                    PHFetchResult<PHAsset *> *assets2 = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
                    if (cameraRoll != nil) {
                        NSDictionary *dic = @{@"title":cameraRoll.localizedTitle,@"assets":assets2,@"count":[NSString stringWithFormat:@"%ld",assets2.count]};
                        [_titleAndAssetsArray addObject:dic];
                    }
                    
                    if (_titleAndAssetsArray.count > 0) {
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:[NSBundle mainBundle]];
                        SeleceAlbumViewController *seleVC = (SeleceAlbumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SeleceAlbumViewController"];
                        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:seleVC];
                        seleVC.dataArray = [_titleAndAssetsArray copy];
                        
                        [UserData userDataStandard].isSeleceArray = [NSMutableArray array];
                        [UserData userDataStandard].photoAssets = [NSMutableArray array];
                        //自定义标题名字和标记图片的名字
                        /* [UserData userDataStandard].firstTitle = @"选择相册";
                         [UserData userDataStandard].twoTitle = @"选择照片";
                         [UserData userDataStandard].markImageName = @"2";*/
                        
                        
                        [self.navigationController presentViewController:navc animated:YES completion:nil];
                    } else {
                        NSLog(@"请先授权相册权限,授权之后再次点击");
                    }
                    
                    
                    
                }
            }];
            
            
            
            UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {//拍照
                
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){//无权限
                    //去设置相机权限
                    UIAlertController *settingalertController = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"您的相机权限尚未开启,是否前去设置-隐私-相机中开启相机权限?" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {//去设置相机权限
                        NSURL *url = [NSURL URLWithString:@"prefs:root=Privacy&path=Photos"];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {     [[UIApplication sharedApplication] openURL:url];
                        }
                    }];
                    [settingalertController addAction:cancelAction];
                    [settingalertController addAction:okAction];
                    [weakSelf presentViewController:settingalertController animated:YES completion:nil];
                } else {
                    // 判断是否支持相机
                    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                    } else {
                        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    }
                    // 跳转到相机或相册页面
                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                    imagePickerController.delegate = self;
                    //imagePickerController.allowsEditing = YES;//是否裁剪原图
                    imagePickerController.sourceType = sourceType;
                    [weakSelf presentViewController:imagePickerController animated:YES completion:^{ }];
                }
            }];
            [albumalertController addAction:albumAction];
            [albumalertController addAction:photoAction];
            [albumalertController addAction:cancelAction];
            [self presentViewController:albumalertController animated:YES completion:nil];
        } else {
            
            NSLog(@"最多只能选择%d张图片",maxNumber);
            
        }
    
}



#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DetailsCollectionViewCell" forIndexPath:indexPath];
    if (_dataArray.count > 0) {
        cell.cousomImageView.image = _dataArray[indexPath.row];
    }
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80*ScaleSize, 80*ScaleSize);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    imageView.image = _dataArray[indexPath.row];
    imageView.hidden = NO;
    
}

//获得通知里面的数据
- (void)getAssetsData:(NSNotification *)Info
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
      
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.networkAccessAllowed = NO;
        //PHImageManagerMaximumSize为原图尺寸, 可以自定义尺寸CGSizeMake(180, 180)
        if ([Info.userInfo[@"assetsArray"] count] > 0) {
            for (int i = 0; i < [Info.userInfo[@"assetsArray"] count]; i++) {
                PHAsset *asset = Info.userInfo[@"assetsArray"][i];
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    [_dataArray addObject:result];
                    
                    if ([asset isEqual:[Info.userInfo[@"assetsArray"] lastObject]]) {
                        [_collectionView reloadData];
                    }
                    
                }];
                
            }
        }
        
    }];
    [operation start];
    
}

//拍照回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    
    if (_dataArray.count < maxNumber) {
    
        //UIImagePickerControllerOriginalImage 原图,  UIImagePickerControllerEditedImage 裁剪过的的图
        [_dataArray addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
        [_collectionView reloadData];
        [picker dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}
- (void)imageTap
{
    imageView.hidden = YES;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PhotoAssets" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
