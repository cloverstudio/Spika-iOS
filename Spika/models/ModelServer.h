//
//  ModelServer.h
//  Spika
//
//  Created by Josip Marković on 28.03.2014..
//
//

#import <Foundation/Foundation.h>

@interface ModelServer : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
