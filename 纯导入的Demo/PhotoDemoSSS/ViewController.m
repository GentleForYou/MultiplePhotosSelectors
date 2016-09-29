//
//  ViewController.m
//  PhotoDemoSSS
//
//  Created by sks on 16/9/23.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import "ViewController.h"
#import "customHeader.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *titleAndAssetsArray;//下个tableview的标题和图片资源
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleAndAssetsArray = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAssetsData:) name:@"PhotoAssets" object:nil];
    
}

//点击按钮,选择图片
- (IBAction)button:(id)sender {
    
        __weak ViewController *weakSelf = self;
    
        //可以选择几张照片(拍照+选图的总数)
        [UserData userDataStandard].photoNumber = 6;//自行修改
            
            UIAlertController *albumalertController = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
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
                } else if (status == PHAuthorizationStatusAuthorized) {//允许访问相册
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
            
            [albumalertController addAction:albumAction];
            [albumalertController addAction:cancelAction];
            [self presentViewController:albumalertController animated:YES completion:nil];

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
                    
                    NSLog(@"%@",result);
                    
                }];
                
            }
        }
        
    }];
    [operation start];
    
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
