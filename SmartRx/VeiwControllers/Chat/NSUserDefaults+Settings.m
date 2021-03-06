//
//  NSUserDefaults+Settings.m
//  SmartRx
//
//  Created by SmartRx-iOS on 21/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "NSUserDefaults+Settings.h"
static NSString * const kSettingExtraMessages           = @"kSettingExtraMessages";
static NSString * const kSettingLongMessage             = @"kSettingLongMessage";
static NSString * const kSettingEmptyMessages           = @"kSettingEmptyMessages";
static NSString * const kSettingSpringiness             = @"kSettingSpringiness";
static NSString * const kSettingIncomingAvatar          = @"kSettingIncomingAvatar";
static NSString * const kSettingOutgoingAvatar          = @"kSettingOutgoingAvatar";
static NSString * const kSettingAccessoryButtonForMedia = @"kSettingAccessoryButtonForMedia";
@implementation NSUserDefaults (Settings)
+ (void)saveExtraMessagesSetting:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSettingExtraMessages];
}

+ (BOOL)extraMessagesSetting
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingExtraMessages];
}

+ (void)saveLongMessageSetting:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSettingLongMessage];
}

+ (BOOL)longMessageSetting
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingLongMessage];
}

+ (void)saveEmptyMessagesSetting:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSettingEmptyMessages];
}

+ (BOOL)emptyMessagesSetting
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingEmptyMessages];
}

+ (void)saveSpringinessSetting:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSettingSpringiness];
}

+ (BOOL)springinessSetting
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingSpringiness];
}

+ (void)saveOutgoingAvatarSetting:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSettingOutgoingAvatar];
}

+ (BOOL)outgoingAvatarSetting
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingOutgoingAvatar];
}

+ (void)saveIncomingAvatarSetting:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSettingIncomingAvatar];
}

+ (BOOL)incomingAvatarSetting
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingIncomingAvatar];
}

+ (BOOL)accessoryButtonForMediaMessages
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingAccessoryButtonForMedia];
}

+ (void)saveAccessoryButtonForMediaMessages:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSettingAccessoryButtonForMedia];
}
@end
