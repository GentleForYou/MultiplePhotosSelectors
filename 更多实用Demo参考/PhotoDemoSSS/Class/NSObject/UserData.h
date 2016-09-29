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
@property (nonatomic)         NSInteger photoNumber;//最多可以选择的照片数

#pragma 自定义的属性
@property (nonatomic, strong) NSString *firstTitle;//第一个页面的标题
@property (nonatomic, strong) NSString *twoTitle;//第二个页面的标题
@property (nonatomic, strong) NSString *markImageName;//选择标记的对号图名字

@end
