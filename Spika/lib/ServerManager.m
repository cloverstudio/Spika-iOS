//
//  ServerManager.m
//  Spika
//
//  Created by Josip Marković on 28.03.2014..
//
//

#import "ServerManager.h"

@implementation ServerManager

+(NSString *)serverBaseUrl {
    NSString *base = [[NSUserDefaults standardUserDefaults] objectForKey:serverBaseURLprefered];
    NSLog(@"base: %@", base);
    if ([base length] > 0) {

        return base;
    }
    else {

        return DefaultAPIEndPoint;
    }
}

@end
