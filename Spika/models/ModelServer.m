//
//  ModelServer.m
//  Spika
//
//  Created by Josip Marković on 28.03.2014..
//
//

#import "ModelServer.h"


@implementation ModelServer

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.name = [dictionary objectForKey:kServerListName];
        self.url = [dictionary objectForKey:kServerListURL];
    }
    
    return self;
}

@end
