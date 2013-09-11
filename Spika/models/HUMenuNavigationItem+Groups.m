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

#import "HUMenuNavigationItem+Groups.h"
#import "OrderedDictionary.h"

@implementation HUMenuNavigationItem (Groups)
+(OrderedDictionary*) groupMenuItems{
    
    OrderedDictionary *dictionary = [OrderedDictionary new];
    
    [dictionary setObject:@[
     [HUMenuNavigationItem navigationItemWithName:NSLocalizedString(@"My Groups", NULL)
                                        imageName:@"icon_groups"
                                 notificationName:NotificationGroupsShowMyGroups],
     
     [HUMenuNavigationItem navigationItemWithName:NSLocalizedString(@"Categories", NULL)
                                        imageName:@"icon_categories"
                                 notificationName:NotificationGroupsShowCategories],
     
     [HUMenuNavigationItem navigationItemWithName:NSLocalizedString(@"Search", NULL)
                                        imageName:@"icon_search"
                                 notificationName:NotificationGroupsShowSearch],
     
     [HUMenuNavigationItem navigationItemWithName:NSLocalizedString(@"Add Group", NULL)
                                        imageName:@"icon_addgroup"
                                 notificationName:NotificationGroupsAddGroup]
     ] forKey:@"Groups"];
    
    return dictionary;
}
@end
