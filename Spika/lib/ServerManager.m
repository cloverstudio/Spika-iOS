//
//  ServerManager.m
//  Spika
//
//  Created by Josip Marković on 28.03.2014..
//
//

#import "ServerManager.h"

@implementation ServerManager

+ (NSString *)serverBaseUrl {
    
    NSString *base = [[NSUserDefaults standardUserDefaults] objectForKey:serverBaseURLprefered];
    return (base && base.length ? base : DefaultAPIEndPoint);
}

@end
