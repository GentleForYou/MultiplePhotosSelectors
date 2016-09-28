//
//  UserData.m
//  PhotoDemoSSS
//
//  Created by sks on 16/9/28.
//  Copyright © 2016年 ALiBaiChuan. All rights reserved.
//

#import "UserData.h"

@implementation UserData

+ (UserData *)userDataStandard
{
    static UserData *userData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        userData = [[UserData alloc] init];
        
    });
    
    return userData;
}

@end
