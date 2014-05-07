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

#import "AppDelegate.h"
#import "HUWallViewController.h"
#import "HUSideMenuViewController.h"
#import "StyleManupulator.h"
#import "HUUsersViewController.h"
#import "HUGroupsViewController.h"
#import "HUMyProfileViewController.h"
#import "HUSettingsViewController.h"
#import "HURecentActivityViewController.h"
#import "UserManager.h"
#import "DatabaseManager.h"
#import "HUGroupProfileViewController.h"
#import "RootVC.h"
#import "CSToast.h"
#import "HUPushNotificationManager.h"
#import "HUOfflinePushNotification.h"
#import "HUDefaultMessageNotification.h"
#import "NSDictionary+KeyPath.h"
#import "NSNotification+Extensions.h"
#import "AlertViewManager.h"
#import "HUPasswordConfirmViewController.h"
#import "UIImage+Aditions.h"
#import "HUMyGroupProfileViewController.h"
#import "Crittercism.h"
#import "HUEULAViewController.h"
#import "HULoginViewController.h"
#import "HUInformationViewController.h"
#import "HUUsersInGroupViewController.h"
#import "HUSubMenuViewController.h"

@interface AppDelegate (){
    UIView *_disableTouchView;
    BOOL    _sideMenuShowing;
    BOOL    _subMenuShowing;
}

@property (nonatomic) BOOL isPasswordInModalPopover;

#pragma mark - Modal Presenting
- (void) presentLoginViewController:(BOOL) animated;

@end

@implementation AppDelegate
{
    HUSideMenuViewController *_subMenuViewController;
}

@synthesize navigationController = _navigationController;

+(AppDelegate *)getInstance {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crittercism enableWithAppID:@"518a1b4b46b7c21aac000006"];
    
    NSDictionary *dic1 = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if(dic1 != nil){
        NSDictionary *dic2 = [dic1 objectForKey:@"data"];
        if(dic2 != nil){
            NSString *valueUser = [dic2 objectForKey:@"from"];
            
            // got user message
            if(valueUser != nil){
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:valueUser forKey:UserDefaultNotificationUserID];
                [userDefault synchronize];
            }
            NSString *valueGroup = [dic2 objectForKey:@"to_group"];
            if(valueGroup != nil){
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:valueGroup forKey:UserDefaultNotificationGroupID];
                [userDefault synchronize];
            }
            
        }
        
    }
    
    [self clearUserDefaults];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
        
    _navigationController = [[CSNavigationController alloc] initWithRootViewController:[[RootVC alloc] init]];
    
    [_navigationController setBackgroundImage:[UIImage imageWithColor:kHUColorDarkDarkGray andSize:CGSizeMake(1, 1)]];
    
    _navigationController.navigationItem.hidesBackButton = YES;
    
    _sideMenuView = [[HUSideMenuViewController alloc] init];
    
    _subMenuViewController = (HUSideMenuViewController *)[[HUSubMenuViewController alloc] init];
    
    [self.window setRootViewController:_navigationController];
    [self.window addSubview:_sideMenuView.view];
    [self.window addSubview:_subMenuViewController.view];
    [self presentLoginViewController:NO];
    [self setupNotifications];
    
    [HUPushNotificationManager setDatasource:self];

    _disableTouchView = [[UIView alloc] initWithFrame:CGRectMake(
            0,
            60,
            self.window.frame.size.width,
            self.window.frame.size.height-60
    )];
    
    _disableTouchView.backgroundColor = [UIColor clearColor];
    
    _sideMenuShowing = NO;
    _subMenuShowing = NO;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowPassword object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{

    
    NSString *strUrl = [NSString stringWithFormat:@"%@",url];
    NSArray *commands = [strUrl componentsSeparatedByString:@"/"];

    NSString *value = nil;
    NSString *command = nil;

    if(commands.count > 2){
        
        value = [commands objectAtIndex:commands.count - 1];
        command = [commands objectAtIndex:commands.count - 2];
        
        value = [[value stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if(command == nil || value == nil)
        return YES;
    
    
    if([[UserManager defaultManager] getLoginedUser] == nil){
    
        // when app is launching
        
        if([command isEqualToString:@"user"] || [command isEqualToString:@"USER"]){
            
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:value forKey:OpenUserName];
            [userDefault synchronize];
            
        }
        
        if([command isEqualToString:@"group"] || [command isEqualToString:@"GROUP"]){
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:value forKey:OpenGroupName];
            [userDefault synchronize];
            
        }
        
    }else{
        
        if([command isEqualToString:@"user"] || [command isEqualToString:@"USER"]){
            
            
            [[DatabaseManager defaultManager] findUserByName:value
                 success:^(id result){
                     
                     if(result == nil){
                         return;
                     }
                     
                     ModelUser *user = (ModelUser *) result;
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile object:user];
                     });
                     
                 } error:^(NSString *error) {
                     
            }];

            
        }
        
        if([command isEqualToString:@"group"] || [command isEqualToString:@"GROUP"]){
            
            [[DatabaseManager defaultManager] findOneGroupByName:value
                 success:^(id result){
                     
                     if(result == nil){
                         return;
                     }
                     
                     ModelGroup *group = (ModelGroup *) result;
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupProfile object:group];
                     });
                     
                 } error:^(NSString *error) {
                     
            }];

            
            
        }

    }
    
    return YES;
 
}

#pragma mark - Modal Presenting

- (void) presentLoginViewController:(BOOL) animated {
    
    
    HULoginViewController *loginVC = [[HULoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
    CSNavigationController *loginNavController = [[CSNavigationController alloc] initWithRootViewController:loginVC];
    
    [loginNavController setBackgroundImage:[UIImage imageWithColor:kHUColorDarkDarkGray andSize:CGSizeMake(1, 1)]];
    
    
    [_navigationController presentViewController:loginNavController
                                        animated:animated
                                      completion:nil];
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *eulaAgreed = [userDefault objectForKey:EULAAgreed];
    
    if(eulaAgreed == nil){
        HUEULAViewController *eulaVC = [[HUEULAViewController alloc] initWithNibName:@"HUEULAView" bundle:nil];
        [loginNavController presentViewController:eulaVC
                                         animated:YES
                                       completion:nil];
    }    
}

//------------------------------------------------------------------------------------------------------
#pragma mark puch notification methods
//------------------------------------------------------------------------------------------------------

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{

    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    
    [[DatabaseManager defaultManager] saveUserPushNotificationToken:[[UserManager defaultManager] getLoginedUser]
                                        token:newToken
                                        success:^(BOOL succees,NSString *errStr){
                                            
                                            
                                            
                                         } error:^(NSString *errStr){

                                         }];
    
    [CSToast showToast:NSLocalizedString(@"Succeed to get notification token", nil) withDuration:5.0];

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	[CSToast showToast:NSLocalizedString(@"Failed to get notification token", nil) withDuration:5.0];
    
    NSLog(@"Failed to register, %@", [error description]);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{

    if([UserManager defaultManager].getLoginedUser == nil)
        return;
    
    if([application applicationState] == UIApplicationStateActive) // Foreground
    {

        ModelUser *user = [UserManager defaultManager].getLoginedUser;
        [[DatabaseManager defaultManager] recentActivityForUser:user
                                                        success:nil
                                                          error:nil];
        
        if (!userInfo) {
            return;
        }
        
        BOOL isGroupNotification = [[userInfo objectForKeyPath:@"data.type"] isEqual:@"group"];
        NSString *_id = [userInfo objectForKeyPath:isGroupNotification ? @"data.to_group" : @"data.from" ];
        
        NSString *compareId = isGroupNotification ? [userInfo objectForKeyPath:@"data.from_user"] : _id;
        if ([[UserManager defaultManager].getLoginedUser._id isEqualToString:compareId]) {
            
            return;
        }
        
        
        if ([self.navigationController.viewControllers.lastObject isKindOfClass:[HUWallViewController class]]) {
            
            if ([[[HUPushNotificationManager defaultManager].target targetId] isEqualToString:_id]) {
                
                HUWallViewController *viewController = self.navigationController.viewControllers.lastObject;
                [viewController reload];
                return;
            }
        }
        
        void(^searchValidTargetBlock)(id model) = ^(id<HUPushNotificationTarget> target) {
            
            HUDefaultMessageNotification *pushMessage = [HUDefaultMessageNotification pushNotificationWithUserInfo:userInfo target:target];
            [pushMessage push];
            
        };
        
        [[DatabaseManager defaultManager] findUserWithID:_id success:^(id result) {
            completion:searchValidTargetBlock(result);
        } error:^(NSString *errorString) {
            
        }];
        

    }else { // Background

        NSDictionary *dic2 = [userInfo objectForKey:@"data"];
        if(dic2 != nil){
            NSString *valueUser = [dic2 objectForKey:@"from"];
            NSString *valueGroup = [dic2 objectForKey:@"to_group"];

            if(valueUser){
                
                [[DatabaseManager defaultManager] findUserWithID:valueUser success:^(id result) {
                    
                    if(result){
                        ModelUser *user = result;
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowUserWall object:user];
                        });
                    }

                    
                } error:^(NSString *errorString) {
                    
                }];
                
                
            }else if(valueGroup){
                
                [[DatabaseManager defaultManager] findGroupByID:valueGroup success:^(id result) {
                    
                    if(result){
                        ModelGroup *group = result;
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:group];
                        });
                    }
                    
                } error:^(NSString *errorString) {
                    
                }];
                
            }
        }
    }
}

//------------------------------------------------------------------------------------------------------
#pragma mark private methods
//------------------------------------------------------------------------------------------------------

- (void) handleAfterLogin:(ModelUser *) user{
    
    [[UserManager defaultManager] setLoginedUser:user];
    
    // check boot by user message notification

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefault objectForKey:UserDefaultNotificationUserID];
    NSString *groupId = [userDefault objectForKey:UserDefaultNotificationGroupID];
    
    NSString *userName = [userDefault objectForKey:OpenUserName];
    NSString *groupName = [userDefault objectForKey:OpenGroupName];
    
    if(userId){
        
        [[DatabaseManager defaultManager] findUserWithID:userId success:^(id result) {

            [[AlertViewManager defaultManager] dismiss];
            
            if(result){
                ModelUser *user = result;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowUserWall object:user];
                });
                
            }else{
                [self openRecentActivity];
            }

        } error:^(NSString *errorString) {
            
        }];
        
        
    }else if(groupId){
        
        [[DatabaseManager defaultManager] findGroupByID:groupId success:^(id result) {
            [[AlertViewManager defaultManager] dismiss];
            
            if(result){
                ModelGroup *group = result;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:group];
                });
            }else{
                [self openRecentActivity];
            }
        } error:^(NSString *errorString) {
            
        }];
        
       
        
    }else if(userName){
        
        [[DatabaseManager defaultManager] findUserByName:userName
            success:^(id result){
                
                [[AlertViewManager defaultManager] dismiss];
                
                if(result == nil){
                    [self openRecentActivity];
                    return;
                }
                
                ModelUser *user = (ModelUser *) result;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile object:user];
                });
                
            } error:^(NSString *error) {
                [self openRecentActivity];
        }];
        
    }else if(groupName){
        
        [[DatabaseManager defaultManager] findOneGroupByName:groupName
             success:^(id result){
                 
                 if(result == nil){
                     [self openRecentActivity];
                     return;
                 }
                 
                 [[AlertViewManager defaultManager] dismiss];
                 
                 ModelGroup *group = (ModelGroup *) result;
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupProfile object:group];
                 });
                 
             } error:^(NSString *error) {
                 [self openRecentActivity];
        }];
        
    }else{
        
        [self openRecentActivity];
        
    }
    
    [userDefault removeObjectForKey:UserDefaultNotificationUserID];
    [userDefault removeObjectForKey:UserDefaultNotificationGroupID];
    [userDefault removeObjectForKey:OpenUserName];
    [userDefault removeObjectForKey:OpenGroupName];
    [userDefault synchronize];

}
- (void) openRecentActivity{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DMFindOneBlock successBlock = ^(id result) {
            
            [[AlertViewManager defaultManager] dismiss];
            
            HURecentActivityViewController *activityViewController = [HURecentActivityViewController newRecentActivityViewController];
            [_navigationController pushViewController:activityViewController animated:NO];
            
        };
        
        DMErrorBlock errorBlock = ^(NSString *error) {
            
            [[AlertViewManager defaultManager] dismiss];
            
            HURecentActivityViewController *activityViewController = [HURecentActivityViewController newRecentActivityViewController];
            [_navigationController pushViewController:activityViewController animated:NO];
        };
        
        [[DatabaseManager defaultManager] recentActivityForUser:[[UserManager defaultManager] getLoginedUser]
            success:^(id result){
                successBlock(result);
            }
            error:errorBlock];
    });
    
}

- (void) setupNotifications{

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationLoginFinished
              object:nil
              queue:[NSOperationQueue mainQueue]
              usingBlock:^(NSNotification *notification) {
                  
                  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                                         UIRemoteNotificationTypeSound)];
                  
                  [_navigationController dismissViewControllerAnimated:YES
                                                            completion:^{
																[[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowPassword object:nil];
															}];
                  
                  
                  ModelUser *user = (ModelUser *)[notification object];
                  [self handleAfterLogin:user];
                  
    }];

    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowSideMenu
          object:nil
           queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *notification) {
          
          //[StyleManupulator attachSideMenuBG:_sideMenuView];
		  [UserManager reloadRecentActivity];
          [self disableTouchInMainView];
          _sideMenuShowing = YES;
          
          [UIView animateWithDuration:0.2
               animations:^{
                   _navigationController.view.x += _sideMenuView.view.width;
                   _sideMenuView.view.x = 0;
               }
               completion:^(BOOL finished){
                   
               }
           ];
      }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationHideSideMenu
          object:nil
           queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *notification) {
          
          [self enableTouchInMainView];
          _sideMenuShowing = NO;
          
          [UIView animateWithDuration:0.2
               animations:^{
                   _navigationController.view.x = 0;
                   _sideMenuView.view.x = -_sideMenuView.view.width;
               }
               completion:^(BOOL finished){
                   
               }
           ];
      }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowSubMenu
              object:nil
               queue:[NSOperationQueue mainQueue]
          usingBlock:^(NSNotification *notification) {
              
               [self disableTouchInMainView];
              _subMenuShowing = YES;
              
              [UIView animateWithDuration:0.2
                               animations:^{
                                   _navigationController.view.x -= _subMenuViewController.view.width;
                                   _subMenuViewController.view.x -=_subMenuViewController.view.width;
                                   _subMenuViewController.items = notification.object;
                               }
                               completion:^(BOOL finished){
                                   
                               }
               ];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationHideSubMenu
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                       [self enableTouchInMainView];
                                                      _subMenuShowing = NO;
                                                      
                                                      [UIView animateWithDuration:0.2
                                                                       animations:^{
                                                                           _navigationController.view.x += _subMenuViewController.view.width;
                                                                           _subMenuViewController.view.x += _subMenuViewController.view.width;
                                                                       }
                                                                       completion:^(BOOL finished){
                                                                           
                                                                       }
                                                       ];
                                                  }];
    

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationSideMenuUsersSelected
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {

            [self clearNavigationVC];
            
            HUUsersViewController *usersVC = [[HUUsersViewController alloc] init];
            [_navigationController pushViewController:usersVC animated:NO]; 
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationSideMenuGroupsSelected
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {

            [self clearNavigationVC];

            HUGroupsViewController *viewController = [[HUGroupsViewController alloc] init];
            [_navigationController pushViewController:viewController animated:NO];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowProfile
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {
            
            ModelUser *user = (ModelUser *)[notification object];
            
            if([user._id isEqualToString:[[UserManager defaultManager] getLoginedUser]._id]){
                [self clearNavigationVC];
                HUMyProfileViewController *myHUProfileViewController = [[HUMyProfileViewController alloc] initWithNibName:@"MyProflieView" bundle:nil];
                [_navigationController pushViewController:myHUProfileViewController animated:YES];
                
            }else{
                HUProfileViewController *viewController = [[HUProfileViewController alloc] initWithNibName:@"UserProfileView" withUser:user];
                [_navigationController pushViewController:viewController animated:YES];
            }
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationUsersInGroup
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      NSDictionary *dict = (NSDictionary *)[notification object];
                                                      NSString *groupID = dict[@"groupID"];
                                                      
//                                                      NSArray *userItems = (NSArray *)(dict[@"userItems"]);
//                                                      ModelGroup *group = (ModelGroup *)dict[@"group"];
//                                                      NSInteger totalItems = [dict[@"totalItems"] integerValue];
//                                                      
                                                      HUUsersInGroupViewController *userListVC = [[HUUsersInGroupViewController alloc] initWithGroupID:groupID];
                                                      [_navigationController pushViewController:userListVC animated:YES];
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowGroupProfile
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {

            ModelGroup *group = (ModelGroup *)[notification object];
            UIViewController *viewController = nil;

            
            if(group.deleted == NO && [UserManager groupBelongsToUser:group]){
                viewController = [[HUMyGroupProfileViewController alloc] initWithNibName:@"MyGroupView" withGroup:group];
            }else{                
                viewController = [[HUGroupProfileViewController alloc] initWithNibName:@"GroupProfileView" withGroup:group];
            }
            
            [_navigationController pushViewController:viewController animated:YES];
            
        }];
    

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationSideMenuMyProfileSelected
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {

            [self clearNavigationVC];
            
            HUMyProfileViewController *myHUProfileViewController = [[HUMyProfileViewController alloc] initWithNibName:@"MyProflieView" bundle:nil];
            [_navigationController pushViewController:myHUProfileViewController animated:YES];

    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationSideMenuPersonalWallSelected
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *note) {
      
            
            [[DatabaseManager defaultManager] findUserWithID:SupportUserId success:^(id result){
                
                [self clearNavigationVC];
                
                ModelUser *user = result;
                
                HUWallViewController *wallVC = [[HUWallViewController alloc] initWithUser:user];
                [_navigationController pushViewController:wallVC animated:NO];

            } error:^(NSString *strError){
                
                
                
            }];
            
        }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationSideMenuLogoutSelected
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {

            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:@"" forKey:UserDefaultLastLoginEmail];
            [userDefault setObject:@"" forKey:UserDefaultLastLoginPass];
            [userDefault synchronize];
            
            [[DatabaseManager defaultManager] doLogout:^(id result) {
                
                [_navigationController popViewControllerAnimated:NO];
                [[UserManager defaultManager] setLoginedUser:nil];
                [self presentLoginViewController:NO];
                
            }];

    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationCriticalError
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Server-Error", nil)];
                                                      [self clearNavigationVC];
                                                      [self presentLoginViewController:NO];
                                                      
                                                      [[UserManager defaultManager] setLoginedUser:nil];
                                                      
                                                      if(_sideMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
                                                      
                                                      if(_subMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSubMenu object:nil];
                                                      
                                                      
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationLogicError
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      NSString *errStr = (NSString *) [notification object];
                                                      [[AlertViewManager defaultManager] showAlert:errStr];
                                                      
                                                      [self presentLoginViewController:NO];
                                                      
                                                      if(_sideMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
                                                      
                                                      if(_subMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSubMenu object:nil];

                                                      
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationTokenExpiredError
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      [[AlertViewManager defaultManager] dismiss];
                                                      [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Token-Expired", nil)];
                                                      [self clearNavigationVC];
                                                      [self presentLoginViewController:NO];
                                                      
                                                      [[UserManager defaultManager] setLoginedUser:nil];

                                                      if(_sideMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
                                                      
                                                      if(_subMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSubMenu object:nil];
                                                      
                                                      
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationServiceUnavailable
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      NSString *errStr = (NSString *) [notification object];
                                                      
                                                      [[AlertViewManager defaultManager] dismiss];
                                                      [[AlertViewManager defaultManager] showAlert:errStr];
                                                      [self clearNavigationVC];
                                                      [self presentLoginViewController:NO];
                                                      
                                                      [[UserManager defaultManager] setLoginedUser:nil];
                                                      
                                                      if(_sideMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
                                                      
                                                      if(_subMenuShowing)
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSubMenu object:nil];
                                                      
                                                      
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowUserWall
          object:nil
          queue:[NSOperationQueue mainQueue]
          usingBlock:^(NSNotification *notification) {
              
              ModelUser *user = (ModelUser *)[notification object];
              
              HUWallViewController *wallVC = [[HUWallViewController alloc] initWithUser:user];
              [_navigationController pushViewController:wallVC animated:YES];
              
          
      }];


    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowGroupWall
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {

            ModelGroup *group = (ModelGroup *)[notification object];

            HUWallViewController *wallVC = [[HUWallViewController alloc] initWithGroup:group];
            [_navigationController pushViewController:wallVC animated:YES];


        }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationDeleteGroup
        object:nil
        queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {

            [_navigationController popToRootViewControllerAnimated:NO];
            
            HUWallViewController *wallVC = [[HUWallViewController alloc] initWithUser:[[UserManager defaultManager] getLoginedUser]];
            [_navigationController pushViewController:wallVC animated:YES];

        }];
	
	[NSNotificationCenter addObserverNamed:NotificationShowInformation usingBlock:^(NSNotification *note) {
		
		[self clearNavigationVC];
		
        HUInformationViewController *informtionViewController = [[HUInformationViewController alloc] initWithNibName:@"InformationView" bundle:nil];
		[_navigationController pushViewController:informtionViewController animated:YES];
		
	}];

    
	[NSNotificationCenter addObserverNamed:NotificationShowSettings usingBlock:^(NSNotification *note) {
		
		[self clearNavigationVC];
		
        HUSettingsViewController *settingsViewController = [[HUSettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
		[_navigationController pushViewController:settingsViewController animated:YES];
		
	}];
	
	[NSNotificationCenter addObserverNamed:NotificationShowRecentActivity usingBlock:^(NSNotification *note) {
		
        [self clearNavigationVC];
        
		DMFindOneBlock successBlock = ^(id result) {
			
			HURecentActivityViewController *activityViewController = [HURecentActivityViewController newRecentActivityViewController];
            [_navigationController pushViewController:activityViewController animated:YES];
			
		};
		
		ModelRecentActivity *activity = [DatabaseManager defaultManager].recentActivity;
		if (activity) {
			successBlock(activity);
			[UserManager reloadRecentActivity];
		} else {
			[[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Recent activity", nil) message:nil];
			ModelUser *user = [UserManager defaultManager].getLoginedUser;
			[[DatabaseManager defaultManager] recentActivityForUser:user
															success:^(id result){
																[[AlertViewManager defaultManager] dismiss];
																successBlock(result);
															}
															  error:nil];
		}
	
	}];
	
    [NSNotificationCenter addObserverNamed:NotificationTuggleSideMenu usingBlock:^(NSNotification *note) {
        if(_sideMenuShowing)
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowSideMenu object:nil];

	}];
    
    [NSNotificationCenter addObserverNamed:NotificationTuggleSubMenu usingBlock:^(NSNotification *notification) {

        if(_subMenuShowing)
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSubMenu object:notification.object];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowSubMenu object:notification.object];
    
        
	}];
    

    
	[NSNotificationCenter addObserverNamed:NotificationShowPassword usingBlock:^(NSNotification *note) {
		
		if (![UserManager defaultManager].getLoginedUser) {
			return ;
		}
		
		id password = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword];
        
		if (!_isPasswordInModalPopover && password) {
			
            if(_sideMenuShowing)
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
            
            if(_subMenuShowing)
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSubMenu object:nil];
            
			_isPasswordInModalPopover = YES;
			HUPasswordInputBlock block = ^(id controller, BOOL isSuccess) {
				if (isSuccess) {
					self.isPasswordInModalPopover = NO;
                    [self.navigationController dismissViewControllerAnimated:YES
                                                                  completion:nil];
				}
			};
			
			HUPasswordConfirmViewController *password = [HUPasswordConfirmViewController forcePasswordViewController:block];
			[_navigationController presentViewController:password animated:YES completion:nil];
		}
		
	}];
    
    HUOfflinePushNotification *offlineNotification = [DatabaseManager defaultManager].offlineNotificationModel;
    HUPushNotificationManager *pushManager = [HUPushNotificationManager defaultManager];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"kNetworkCrittercismReachabilityChangedNotification"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
        
                                                      if ([[HUHTTPClient sharedClient] isInternetAvailable]) {
                                                          [pushManager removePushNotification:offlineNotification];
                                                      }
                                                      else {
                                                          [pushManager removePushNotification:offlineNotification];
                                                      }
    }];
}


#pragma mark - HUPushNotificationDatasource

-(void) clearNavigationVC{
    
    while(_navigationController.viewControllers.count != 1){
        [_navigationController popViewControllerAnimated:NO];
    }
    
}
-(UIViewController *) presentingViewController {
    
    return self.navigationController;
}

-(void) disableTouchInMainView{
    [_navigationController.view addSubview:_disableTouchView];
}

-(void) enableTouchInMainView{
    [_disableTouchView removeFromSuperview];
}

-(void) clearUserDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:kOneTimeMsgNoContact];
    [defaults removeObjectForKey:kOneTimeMsgNoFavorite];
    [defaults removeObjectForKey:DidAlreadyAutoSignedIn];
    
    [defaults synchronize];
}


@end