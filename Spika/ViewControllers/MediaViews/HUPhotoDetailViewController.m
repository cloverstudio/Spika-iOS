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

#import "HUPhotoDetailViewController.h"
#import "HUBaseViewController+Style.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "CSToast.h"
#import "MessageTypeImageDetailCell.h"
#import "AlertViewManager.h"
#import "HUCachedImageLoader.h"

@interface HUPhotoDetailViewController (){

}

@property (nonatomic, strong) UIImage *image;


@end

@implementation HUPhotoDetailViewController

-(MessageTypeBasicCell *) getMediaCellWithMessage:_message indexPath:(NSIndexPath *) indexPath{
    
    NSString *cellIdentifier = @"MessageTypeImageDetailCell";
    
    MessageTypeImageDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        
        cell = [[MessageTypeImageDetailCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:cellIdentifier];
        [cell setDelegate:self];
        
        
    }
    
    ModelMessage *message = self.items[0];
    message.value = self.image;
    
    MessageTypeBasicCell *wallCell = (MessageTypeBasicCell *)cell;
    [wallCell updateWithModel:message];
    
    [HUCachedImageLoader imageFromUrl:self.message.avatarThumbUrl completionHandler:^(UIImage *image) {
        if(image)
            wallCell.avatarIconView.image = image;
    }];
    
    return wallCell;
    
}

-(void) reload {
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    [[DatabaseManager defaultManager] loadImage:self.message.imageUrl success:^(UIImage *image) {
        
        [[AlertViewManager defaultManager] dismiss];
        
        self.image = image;
        
        [super reload];
        
    } error:^(NSString *errorString) {
        [self setViewType:HUViewTypeNoItems];
    }];
    
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ModelMessage *message = [self.items objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        return [MessageTypeImageDetailCell cellHeightForImage:self.image];
    }
    else
    {
        return [message.tableViewCellClass cellHeightForMessage:message];
    }
}

@end
