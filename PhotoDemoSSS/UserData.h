//
//  UserData.h
//  PhotoDemoSSS
//
//  Created by sks on 16/9/28.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//  传递数据的单例

#import <Foundation/Foundation.h>

@interface UserData : NSObject

+ (UserData *)userDataStandard;

@property (nonatomic, strong) NSMutableArray *isSeleceArray;//记录item是否选中
@property (nonatomic, strong) NSMutableArray *photoAssets;//传出来的数据Assets
@property (nonatomic)         unsigned int photoNumber;//最多可以选择的照片数

@end
