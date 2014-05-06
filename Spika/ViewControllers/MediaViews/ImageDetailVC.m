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

#import "ImageDetailVC.h"
#import "StyleManupulator.h"

#import "Utils.h"
#import "StdTextView.h"
#import "StrManager.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "CSToast.h"
#import "ImageMessageCommentRow.h"
#import "AlertViewManager.h"

#define TbViewHeight 24
#define TbViewMargin 5
#define BtnWidth 50
#define ImageViewSize 300
#define ImageViewMargin 5
#define InfoLabelHeight 25

@interface ImageDetailVC ()

@end

@implementation ImageDetailVC

- (id)initWithMessage:(ModelMessage *)message
{
    self = [super init];
    if (self) {
        
        self.title = NSLocalizedString(@"Image Detail", nil);
        _message = message;
        
        [self buildViews];
        [self buildComments];
    }
    return self;
}


- (void)viewDidLoad
{
    [self hideMenuBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------------------------------
#pragma mark private methods
//------------------------------------------------------------------------------------------------------

- (void) reloadData{
    
    [[DatabaseManager defaultManager]
     reloadMessage:_message
     success:^(NSObject *model){
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if(model == nil)
                 return;
             
             _message = (ModelMessage *)model;
             [self buildComments];
             
             CGPoint bottomOffset = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
             [_scrollView setContentOffset:bottomOffset animated:YES];
             
         });
         
     } error:^(NSString *errStr){
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [CSToast showToast:errStr withDuration:3.0];
             
         });
         
     }];

}

- (void)buildViews{
    
    [StyleManupulator attachDefaultBG:self.view];
    
    int holderHeight = TbViewHeight + TbViewMargin * 2;
    
    _viewMessageInputHolder = [[UIView alloc] initWithFrame:CGRectMake(
       0,
       self.view.frame.size.height - holderHeight - HeaderHeight,
       [Utils getDisplayWidth],
       holderHeight+JapaneseSuggestionAreaHeight)];
    
    [StyleManupulator attachWallTextViewBG:_viewMessageInputHolder];
    
    CGRect textViewRect = CGRectMake(
         TbViewMargin,
         TbViewMargin,
         self.view.frame.size.width - TbViewMargin * 2 - BtnWidth * 1,
         TbViewHeight
    );
    
    _tvMessageInput = [[StdTextView alloc] init];
    _tvMessageInput.frame = textViewRect;
    _tvMessageInput.delegate = self;
    [StyleManupulator attachWallTextView:_tvMessageInput];
    
    CGRect sendBtnRect = CGRectMake(
        TbViewMargin + _tvMessageInput.frame.size.width + TbViewMargin,
        TbViewMargin,
        BtnWidth,
        TbViewHeight
    );

    
    _btnSend = [CSButton buttonWithFrame:sendBtnRect callback:^{
        
        [self.view endEditing:YES];
        
        [[DatabaseManager defaultManager]
                postImageComment:_message
                byUser:[[UserManager defaultManager] getLoginedUser]
                comment:_tvMessageInput.text
                success:^(BOOL isSuccess,NSDictionary *result){

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(isSuccess == NO){
                    [CSToast showToast:[StrManager _:NSLocalizedString(@"Failed to post comment", nil)]
						  withDuration:3.0];
                    return;
                }
                
                _tvMessageInput.text = @"";
                [self reloadData];
                
            });

        } error:^(NSString *errStr){

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [CSToast showToast:errStr withDuration:3.0];
                
            });
            

        }]; // postImageComment:_message

        
        
    }]; // _btnSend = [CSButton buttonWithFrame:sendBtnRect callback:^{
    
    
    [_btnSend setTitle:[StrManager _:@"send"] forState:UIControlStateNormal];
    
    
    [StyleManupulator attachWallButtons:_btnSend];
    
    
    [_viewMessageInputHolder addSubview:_tvMessageInput];
    [_viewMessageInputHolder addSubview:_btnSend];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(
        0,
        0,
        self.view.frame.size.width,
        self.view.frame.size.height - HeaderHeight - holderHeight
    );
    
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width,1000);
    [self.view addSubview:_scrollView];
    
    _holderView = [[UIView alloc] init];
    int holderViewWidth = ImageViewSize + ImageViewMargin * 2;
    _holderView.frame = CGRectMake(
        (self.view.frame.size.width - holderViewWidth) / 2,
        TbViewMargin,
        holderViewWidth,
        holderViewWidth
    );
    [StyleManupulator attachMessageImageViewFrameStyle:_holderView];
    [_scrollView addSubview:_holderView];

    _imageViewMessage = [[UIImageView alloc] init];
    _imageViewMessage.frame = CGRectMake(
       ImageViewMargin,
       ImageViewMargin,
       ImageViewSize,
       ImageViewSize
    );
    [_holderView addSubview:_imageViewMessage];
    
    _labelInfo = [[UILabel alloc] init];
    _labelInfo.frame = CGRectMake(
        (self.view.frame.size.width - holderViewWidth) / 2,
        _holderView.frame.origin.y + holderViewWidth + TbViewMargin,
        holderViewWidth,
        InfoLabelHeight
    );
    
    _labelInfo.numberOfLines = 1;
    _labelInfo.text = [Utils generateMessageInfoText:_message];
    
    [StyleManupulator attachTextMessageInfoLabel:_labelInfo];
    [_scrollView addSubview:_labelInfo];

    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    [[DatabaseManager defaultManager] loadImage:_message.imageUrl
     
    success:^(UIImage *image){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[AlertViewManager defaultManager] dismiss];
            
            if(image == nil){
                return;
            }
            
            _imageViewMessage.image = image;
            
        });
        
        
    } error:^(NSString *errStr){
        
        
    }];
 
    [self.view addSubview:_viewMessageInputHolder];
}

-(void) buildComments{
    
    for(int i = 0; i < _commentBlocks.count ; i++){
        
        UIView *holder = [_commentBlocks objectAtIndex:i];
        
        if(holder != nil)
            [holder removeFromSuperview];
        
    }
    
    [_commentBlocks removeAllObjects];
    
    int currentYPos = _labelInfo.frame.origin.y + _labelInfo.frame.size.height;
    
    for(int i = 0; i < _message.comments.count ; i++){
        
        ImageMessageCommentRow *row = [[ImageMessageCommentRow alloc] initWithComment:[_message.comments objectAtIndex:i]];

        row.frame = CGRectMake(
            0,
            currentYPos,
            self.view.frame.size.width,
            [ImageMessageCommentRow calcCellHeight:[[_message.comments objectAtIndex:i] objectForKey:@"comment"]]
        );
        
        [_scrollView addSubview:row];
        
        [_commentBlocks addObject:row];
        
        currentYPos += row.frame.size.height;
        
    }
    
    if(currentYPos < 500)
        currentYPos = 500;
    
    _scrollView.contentSize = CGSizeMake([Utils getDisplayWidth],currentYPos);

    

    
}
//------------------------------------------------------------------------------------------------------
#pragma mark UITextFieldDelegate methods
//------------------------------------------------------------------------------------------------------

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    int bringupHeight = KeyboardHeight;
    UITextInputMode *current = [[UITextInputMode activeInputModes] firstObject];
    NSString *keyboardLanguage = current.primaryLanguage;
    
    if([keyboardLanguage rangeOfString:@"ja"].location != NSNotFound){
        bringupHeight += JapaneseSuggestionAreaHeight;
    }
    
    _currentKeyboardHeight = bringupHeight;
    
    [UIView animateWithDuration:0.2
         animations:^{
             _viewMessageInputHolder.frame = CGRectMake(
                _viewMessageInputHolder.frame.origin.x,
                _viewMessageInputHolder.frame.origin.y - _currentKeyboardHeight,
                _viewMessageInputHolder.frame.size.width,
                _viewMessageInputHolder.frame.size.height
                );
             
         }
         completion:^(BOOL finished){
             
         }
     ];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [UIView animateWithDuration:0.2
         animations:^{
             
             _viewMessageInputHolder.frame = CGRectMake(
                _viewMessageInputHolder.frame.origin.x,
                _viewMessageInputHolder.frame.origin.y + _currentKeyboardHeight,
                _viewMessageInputHolder.frame.size.width,
                _viewMessageInputHolder.frame.size.height
                );
             
         }
         completion:^(BOOL finished){
             
         }
     ];
    
}


@end
