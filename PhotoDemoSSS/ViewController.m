//
//  ViewController.m
//  PhotoDemoSSS
//
//  Created by sks on 16/9/23.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "SeleceAlbumViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) NSInteger photoNumber;
@property (nonatomic, strong) NSMutableArray *titleAndAssetsArray;//下个tableview的标题和图片资源
@end

@implementation ViewController
#warning 1.在AppDelegate中设置photoArray,每次进入demo都是空数组 2.iOS 10 下真机NSLog打印无效,想打印的自己百度  3. ios10在infoPlist里面添加字段

- (void)viewDidLoad {
    [super viewDidLoad];
    //可以选择几张照片(拍照+选图的总数)
    _photoNumber = 10;
    _titleAndAssetsArray = [NSMutableArray array];
    
//    [self getOriginalImages];
    
}

//点击按钮,选择图片
- (IBAction)button:(id)sender {
    
        __weak ViewController *weakSelf = self;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"photoArray"] count] < _photoNumber) {
       
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
            } else {//允许访问相册
                // 获得所有的自定义相簿
                PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                // 遍历所有的自定义相簿
                for (PHAssetCollection *assetCollection in assetCollections) {
                    PHFetchResult<PHAsset *> *assets1 = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                    NSDictionary *dic = @{@"title":assetCollection.localizedTitle,@"assets":assets1,@"count":[NSString stringWithFormat:@"%ld",assets1.count]};
                    [_titleAndAssetsArray addObject:dic];
                }
                
                // 获得相机胶卷,  estimatedAssetCount这个属性,在自定义相册里面返回的照片数是正确的,在相机胶圈中,返回的是不正确的
                PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
                // 获得某个相簿中的所有PHAsset对象
                PHFetchResult<PHAsset *> *assets2 = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
                NSDictionary *dic = @{@"title":cameraRoll.localizedTitle,@"assets":assets2,@"count":[NSString stringWithFormat:@"%ld",assets2.count]};
                [_titleAndAssetsArray addObject:dic];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                SeleceAlbumViewController *seleVC = (SeleceAlbumViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SeleceAlbumViewController"];
                UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:seleVC];
                seleVC.dataArray = [_titleAndAssetsArray copy];
                [self.navigationController presentViewController:navc animated:YES completion:nil];
                
                
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
        NSLog(@"最多只能选择%ld张图片",_photoNumber);
    }
    
}

//拍照回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    
    if ([[userDefault objectForKey:@"photoArray"] count] < _photoNumber) {
        
        //UIImagePickerControllerOriginalImage 原图,  UIImagePickerControllerEditedImage 裁剪过的的图
        [[userDefault objectForKey:@"photoArray"] addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
        [picker dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end