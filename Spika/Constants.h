/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio Ltd. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */
#import "ServerManager.h"

#define ServerListAPIURL        @"http://officialapi.spikaapp.com/api/servers"

/* change here */
#define DefaultAPIEndPoint             @"http://officialapi.spikaapp.com"
#define DefaultPageUrl             @"http://officialapi.spikaapp.com/page"
/* end change here */

#define DatabaseURL             [NSString stringWithFormat:@"%@/api",[ServerManager serverBaseUrl]]
#define HttpRootURL             [NSString stringWithFormat:@"%@/api",[ServerManager serverBaseUrl]]
#define PageRootURL             [NSString stringWithFormat:@"%@/page",[ServerManager serverBaseUrl]]
#define InformationPageTopURL   [NSString stringWithFormat:@"%@/page/information",[ServerManager serverBaseUrl]]

#ifndef Bind_Constants_h
#define Bind_Constants_h

#define kIsDebugMode	NO

/*  Fonts */
#pragma mark - Fonts
#define kFontArialMT                @"ArialMT"
#define kFontArialMTBold            @"Arial-BoldMT"
#define kFontArialMTOfSize(__SIZE__)                [UIFont fontWithName:kFontArialMT size:__SIZE__]
#define kFontArialMTBoldOfSize(__SIZE__)            [UIFont fontWithName:kFontArialMTBold size:__SIZE__]
#define kFontSizeExtraBig               50
#define kFontSizeBig                    20
#define kFontSizeMiddium                16
#define kFontSizeSmall                  12

/* Database */
#pragma mark - Database

#define AuthURL                 @"auth"
#define FileUplaoder            @"/fileuploader"
#define FileDownloader          @"/filedownloader"
#define ReminderURL             @"resetPassword"

#define PagingMessageFetchNum   20
#define PagingUserFetchNum      20

#define DefaultContactNum       20
#define DefaultFavoriteNum      10

#define SupportUserId           @"1"

// UI element constants
#define StdUIElementHeight 35
#define StdUIButtonWidth 100
#define HeaderHeight 44
#define KeyboardHeight 216
#define JapaneseSuggestionAreaHeight 35
#define BarButtonWidth  90
//#define MediaBtnWidth 107
//#define MediaBtnHeight 100

#define MediaBtnWidth 71
#define MediaBtnHeight 69

#define AvatarThumbNailSize 120
#define AvatarSize          640
#define ImageMessageSize    640
#define ImageMessageThumbSize    240

#define AvatarT
// Notifications
#define NotificationLoginFinished                       @"loginFinished"
#define NotificationShowSideMenu                        @"showSideMenu"
#define NotificationHideSideMenu                        @"hideSideMenu"
#define NotificationSideMenuUsersSelected               @"sideMenuUsers"
#define NotificationSideMenuGroupsSelected              @"sideMenuGroups"
#define NotificationShowProfile                         @"showProflie"
#define NotificationShowGroupProfile                    @"showGroupProflie"
#define NotificationShowUserWall                        @"showUserWall"
#define NotificationShowGroupWall                       @"showGroupWall"
#define NotificationNewGroupCancel                      @"newGroupCancel"
#define NotificationNewGroupCreated                     @"newGroupCreated"
#define NotificationSideMenuMyProfileSelected           @"showMyProfile"
#define NotificationSideMenuPersonalWallSelected        @"showPersonalWall"
#define NotificationSideMenuLogoutSelected              @"logout"
#define NotificationOpenEditGroup                       @"openEditGroup"
#define NotificationGroupUpdated						@"groupUpdated"
#define NotificationDeleteGroup                         @"groupDeleted"
#define NotificationShowRecentActivity                  @"showRecentActivity"
#define NotificationShowInformation                     @"showInformation"
#define NotificationShowSettings                        @"showSettings"
#define NotificationShowPassword                        @"showPassword"
#define NotificationShowSubMenu                         @"showSubMenu"
#define NotificationHideSubMenu                         @"hideSubMenu"
#define NotificationShowUsersSearch                     @"showUsersSearch"
#define NotificationShowUsersExplore                    @"showUsersExplore"
#define NotificationShowUsersMyContacts                 @"showMyContacts"
#define NotificationGroupsAddGroup                      @"groupsAddGroup"
#define NotificationGroupsShowMyGroups                  @"groupsShowMyGroups"
#define NotificationGroupsShowSearch                    @"groupsShowSearch"
#define NotificationGroupsShowCategories				@"groupsShowCategories"
#define NotificationCriticalError                       @"criticalError"
#define NotificationLogicError                          @"logicError"
#define NotificationTokenExpiredError                   @"tokenExpired"
#define NotificationServiceUnavailable                  @"ServiceUnavailable"
#define NotificationTuggleSideMenu                      @"tuggleSideMenu"
#define NotificationTuggleSubMenu                       @"tuggleSubMenu"
#define NotificationReportViolation                     @"reportViolation"
#define NotificationUsersInGroup                        @"usersInGroup"

// UserDefaultKeys
#define UserDefaultLastLoginEmail @"lastLoginEmail"
#define UserDefaultLastLoginPass @"lastLoginPass"
#define UserDefaultPassword		@"localPassword"
#define UserDefaultAPIEndpoint	@"localApiEndpoint"
#define UserPassword            @"userpassword"
#define UserToken               @"usertoken"
#define UserDefaultNotificationUserID		@"notificationUserId"
#define UserDefaultNotificationGroupID		@"notificationGroupId"
#define OpenUserName         @"openusername"
#define OpenGroupName		@"opengroupname"
#define DidAlreadyAutoSignedIn             @"DidAlreadyAutoSignedIn"
#define LastOpenedGroupWall             @"LastOpenedGroupWall"
#define EULAAgreed              @"EULAAgreed"
#define serverBaseURLprefered @"serverBaseUrlPrefered"
#define serverBaseNamePrefered @"serverBaseNamePrefered"

// Timer
#define AutoReloadInterval 5.0f

// Model
#define MessageTypeImageFileName @"image.jpg"
#define MessageTypeVideoFileName @"video.mov"
#define UserAvatarImageFileName @"avatar.jpg"
#define GroupAvatarImageFileName @"group_image.jpg"
#define MessageTypeVoiceFileName @"voice.wav"
#define MessageTypeVoiceRecievedFileName @"voice_recieved.wav"

// Password
#define HUPasswordLength 4

// Color
#define kHUColorDarkDarkGray        UIColorFromRGB(0x090909)
#define kHUColorDarkGray            UIColorFromRGB(0x1f1f1f)
#define kHUColorGrayMenu            UIColorFromRGB(0x1b1b1b)
#define kHUColorGrayMenuSeparator   UIColorFromRGB(0x242424)

#define kHUColorLightGray           UIColorFromRGB(0x7D7D7D)
#define kHUColorGreen               UIColorFromRGB(0x00CC7B)
#define kHUColorLightRed            UIColorFromRGB(0xE81757) 
#define kHUColorWhite               [UIColor whiteColor]

//in seconds...
#define kVideoMaxLength		30.0f
#define kAudioMaxLength		10.0f

// Messages
#define kOneTimeMsgNoContact @"kOneTimeMsgNoContact"
#define kOneTimeMsgNoFavorite @"kOneTimeMsgNoFavorite"

// thimbnails
#define kListViewSmallWidht 100
#define kListViewBigWidth 200

// date formate
#define kDefaultDateFormat @"YYYY.MM.dd"
#define kDefaultTimeStampFormat @"YYYY.MM.dd HH:mm"

// data sources
#define kGenderDataSource    @[ @"Male", @"Female", @"No declaration" ]
#define kStatusDataSource   @[ @"online", @"away", @"busy", @"offline" ]
#define kStatusImageNames @[ @"user_online_icon", @"user_away_icon", @"user_busy_icon", @"user_offline_icon" ]
#define kServerListName @"name"
#define kServerListURL @"url"

#endif

typedef NSString* HUGender;

static const HUGender HUGenderMale = @"male";
static const HUGender HUGenderFemale = @"female";
static const HUGender HUGenderNone = @"";
