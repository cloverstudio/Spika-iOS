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

#import "HUBaseViewController.h"
#import "HUBaseViewController+Style.h"
#import "NSNotification+Extensions.h"
#import "UIResponder+Extension.h"
#import "AlertViewManager.h"
#import "UINavigationItem+AutoScrollLabel.h"
#import "AppDelegate.h"

@interface HUBaseViewController () {

    UIButton                    *_slideButton;

}

#pragma mark - Notifications Subscribing And Unsubscribing
- (void) subscribeForKeyboardNotification:(const NSString *)notificationName
                               usingBlock:(void (^)(NSNotification *note))block;

- (void) unsubscribeForNotificationWithName:(const NSString *)notificationName;

@end

@implementation HUBaseViewController

#pragma mark - Initialization

+(void) initialize {
	
	[[UISwitch appearance] setOnTintColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen]];
}

- (id) init {

    if (self = [super init]) {
		
		_isDebugMode = kIsDebugMode;
        _allowSwipe = YES;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (BOOL) showTutorialIfCan:(NSString *)message{
    
    NSString *key = [NSString stringWithFormat:@"tutorialshowed_%@",NSStringFromClass([self class])];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:key] == nil){
        [[AlertViewManager defaultManager] showTutorial:message];
        [defaults setObject:@"true" forKey:key];
        [defaults synchronize];
        
        return YES;
    }
    
    
    return NO;

}

- (void) showOneTimeAfterBootMessage:(NSString *)message key:(NSString *)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:key] == nil){
        [[AlertViewManager defaultManager] showTutorial:message];
        [defaults setObject:@"true" forKey:key];
        [defaults synchronize];
    }
    
}

- (UIView*)viewFromNib {
    
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"nib"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName]) {
        
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        if ([views count])
            return [views objectAtIndex:0];
    }
    return nil;
}

- (void)loadView {
    
    [super loadView];
    
    
    self.navigationItem.rightBarButtonItems = [HUBaseViewController dummyBarButtonItem];
    self.view.userInteractionEnabled = YES;
    
    if ([NSStringFromClass([self class]) isEqualToString:@"HULoginViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"HUSignUpViewController"]) {
        
        self.navigationItem.hidesBackButton = YES;
        
        return;
    }
	
	if (_isDebugMode) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
		label.text = NSStringFromClass([self class]);
		label.center = CGPointMake(self.view.width / 2, self.view.height / 2);
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.backgroundColor = [UIColor yellowColor];
		[UIView animateWithDuration:1.0
						 animations:nil
						 completion:^(BOOL finished) { [self.view addSubview:label]; }];
	}
    
     
    
    UISwipeGestureRecognizer *oneFingerSwipeRight =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeForMenu)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
    
    UISwipeGestureRecognizer *oneFingerSwipeLeft =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeForSubMenu)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    
}
 

- (void) swipeForMenu{
    
    if(_allowSwipe == NO)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTuggleSideMenu object:nil];
}


- (void) swipeForSubMenu{
    
    if(_allowSwipe == NO)
        return;
    
    if([self respondsToSelector:@selector(toggleSubMenu:)]){
        [self performSelector:@selector(toggleSubMenu:) withObject:nil];
    }

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
}

// Add this Method
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray *views = [AppDelegate getInstance].navigationController.viewControllers;
    
    if(views.count > 2)
        [self addBackButton];
    else
        [self addSlideButtonItem];
 
}
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([self.navigationItem respondsToSelector:@selector(readjustLayout)])
        [self.navigationItem performSelector:@selector(readjustLayout)];

    __weak HUBaseViewController *this = self;

    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowSideMenu
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [this.view endEditing:NO];
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationHideSideMenu
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [this.view endEditing:NO];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowSubMenu
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [this.view endEditing:NO];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationHideSubMenu
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [this.view endEditing:NO];
                                                  }];

}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowSideMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationHideSideMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationHideSubMenu object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Observing

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {

    if ([keyPath isEqualToString:@"viewType"]) {
        
        [self showViewType:_viewType animated:NO];
    }
}

#pragma mark - PushNotification

-(void) presentPushNotificationView:(UIView *)view {
    [self presentPushNotificationView:view completion:nil];
}

-(void) presentPushNotificationView:(UIView *)view completion:(CSVoidBlock)block {
    
}

-(void) dismissPushNotificationView:(UIView *)view {
    [self dismissPushNotificationView:view completion:nil];
}

-(void) dismissPushNotificationView:(UIView *)view completion:(CSVoidBlock)block {
    
}

#pragma mark - View States

- (void) showViewType:(HUViewType)viewType animated:(BOOL)animated {
    
    //Override me
}

#pragma mark - Keyboard Notifications
- (void) subscribeForKeyboardWillShowNotificationUsingBlock:(void (^)(NSNotification *note))block {
    
    [self subscribeForKeyboardNotification:UIKeyboardWillShowNotification
                                usingBlock:block];
}

- (void) subscribeForKeyboardWillChangeFrameNotificationUsingBlock:(void (^)(NSNotification *note))block {

    [self subscribeForKeyboardNotification:UIKeyboardWillChangeFrameNotification
                                usingBlock:block];
}

- (void) subscribeForKeyboardWillHideNotificationUsingBlock:(void (^)(NSNotification *note))block {

    [self subscribeForKeyboardNotification:UIKeyboardWillHideNotification
                                usingBlock:block];
}

- (void) unsubscribeForKeyboardWillShowNotification {

    [self unsubscribeForNotificationWithName:UIKeyboardWillShowNotification];
}

- (void) unsubscribeForKeyboardWillChangeFrameNotification {

    [self unsubscribeForNotificationWithName:UIKeyboardWillChangeFrameNotification];
}

- (void) unsubscribeForKeyboardWillHideNotification {

    [self unsubscribeForNotificationWithName:UIKeyboardWillHideNotification];
}

#pragma mark - Notifications Subscribing And Unsubscribing

- (void) subscribeForKeyboardNotification:(const NSString *)notificationName
                               usingBlock:(void (^)(NSNotification *note))block {

    [[NSNotificationCenter defaultCenter] addObserverForName:(NSString *)notificationName
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:block];
}

- (void) unsubscribeForNotificationWithName:(const NSString *)notificationName {

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:(NSString *)notificationName
                                                  object:nil];
}

#pragma mark - Titles

- (NSString *) loadingTitle {

    return NSLocalizedString(@"Loading", nil);
}

- (NSString *) noItemsTitle {

    return NSLocalizedString(@"No-Items", nil);
}

#pragma mark - Adding Buttons

- (void) addSlideButtonItem {
    
    UIBarButtonItem *barButtonItem = [CSKit barButtonItemWithNormalImageNamed:@"hp_slide_button"
                                                                  highlighted:nil
                                                                       target:self
                                                                     selector:@selector(onSlide:)];
    
    barButtonItem.isAccessibilityElement = YES;
    barButtonItem.accessibilityLabel = @"slidebutton";
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
}

- (void) addBackButton {
    self.navigationItem.leftBarButtonItems = [self backBarButtonItemsWithSelector:@selector(onBack:)];
}

-(void) hideMenuBtn {
 
    self.navigationItem.hidesBackButton = NO;
    [self.navigationItem setLeftBarButtonItem:nil];
}

-(void) showMenuBtn{
    
    [self.navigationItem setLeftBarButtonItem:_leftButtonShowMenu];
}

#pragma mark - Button Selectors

- (void) showButtonPressed{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowSideMenu object:nil];
    [self.navigationItem setLeftBarButtonItem:_leftButtonHideMenu];
}


- (void) hideNavButtonPressed{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
    [self.navigationItem setLeftBarButtonItem:_leftButtonShowMenu];
}

- (void) onSlide:(id) sender {

    [[UIResponder currentFirstResponder] resignFirstResponder];
    
    BOOL isViewOpened = self.navigationController.view.x == 0 ? NO : YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:(isViewOpened ?
                                                                NotificationHideSideMenu :
                                                                NotificationShowSideMenu)
                                                        object:nil];    
}
- (void) onBack:(id) sender {

    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Override

- (void) hideView:(UIView *)view{
    CGRect rect = view.frame;
    rect.size.height = 0;
    view.frame = rect;
}

- (void) showView:(UIView *)view height:(int) height{
    CGRect rect = view.frame;
    rect.size.height = height;
    view.frame = rect;
}

-(void)runOnMainQueueWithoutDeadlocking:(CSVoidBlock)block
{
	if ([NSThread isMainThread])
		block();
	else
		dispatch_sync(dispatch_get_main_queue(), block);
}

#pragma mark - Keyboard Done Button

- (void) showKeyboardDoneButtonForTextView:(UITextView *) textView
{
    UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                     [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithKeyboardWithDoneButton)],
                           nil];
    [toolbar sizeToFit];
    textView.inputAccessoryView = toolbar;
    _textViewForKeyboardWithDoneButton = textView;
}

- (void) doneWithKeyboardWithDoneButton
{
    [_textViewForKeyboardWithDoneButton resignFirstResponder];
}

@end
