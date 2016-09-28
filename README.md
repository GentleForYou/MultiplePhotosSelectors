# MultiplePhotosSelectors
##多图选择器

自定义多图选择器,适用 iOS8以上, 兼容iOS10

* ios10系统下真机NSLog,不打印数据,需要打印的话自行百度NSLog
* iOS10在infoPlist里面加 Privacy - Camera Usage Description, Privacy - Photo Library Usage Description,两个字段
* iOS10需在Build Phases -- Link Binary With Libraries 添加Photo.framework框架

> 使用:
> 

1. 下载demo,将Class,导入自己的项目,在需要使用的地方引入头文件 #import "customHeader.h" 
* 注册通知,并且判断相机权限,权限正确之后才进入相册,具体的相机相册权限判断Demo里面写的很详细,可以参考

~~~
//注册通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAssetsData:) name:@"PhotoAssets" object:nil];
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
~~~
~~~
//获取相册权限之后才进入
[UserData userDataStandard].photoNumber = 6;//最大可选择的相册数,自行修改,默认是6
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
     [self.navigationController presentViewController:navc animated:YES completion:nil];
                    } else {
                        NSLog(@"请先授权相册权限,授权之后再次点击");
                    }

~~~