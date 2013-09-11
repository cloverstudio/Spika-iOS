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

#import "HURadioButton.h"
#import "UIImage+NoCache.h"
#import "CSGraphics.h"

@implementation HURadioButton

#pragma mark - Initialization

- (id)initWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    self = [super initWithFrame:CGRectMakeBoundsWithSize(image.size)];
    if (self) {
        // Initialization code
        self.linkedButtons = [NSMutableArray new];
        self.normalImage = image;
        self.selectedImage = selectedImage;
        
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:selectedImage forState:UIControlStateSelected];
        [self setSelected:NO];
        
        [self addTarget:self action:@selector(radioButtonDidTapInsideOut:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - Selector

-(void) radioButtonDidTapInsideOut:(HURadioButton *)button {
    [self setSelected:!self.selected];
}

#pragma mark - Helper

+(void) linkButtons:(HURadioButton *)button, ... {
    
    NSMutableArray *buttonsArray = [NSMutableArray new];
    
    va_list args;
    va_start(args, button);
    for (HURadioButton *arg = button; arg != nil; arg = va_arg(args, HURadioButton*))
    {
        [buttonsArray addObject:arg];
    }
    va_end(args);
    
    for (HURadioButton *aButton in buttonsArray) {
    
        [aButton.linkedButtons removeAllObjects];
        [aButton.linkedButtons addObjectsFromArray:buttonsArray];
        [aButton.linkedButtons removeObject:aButton];
    }
}

-(void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setImage:selected ? self.normalImage : self.selectedImage forState:UIControlStateHighlighted];
    if (selected) {
        for (HURadioButton *button in self.linkedButtons) {
            [button setSelected:NO];
        }
    }
}

@end

@implementation HURadioButton (Factory)

+(HURadioButton *) buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    return [[self alloc] initWithImage:image selectedImage:selectedImage];
}

+(HURadioButton *) buttonWithImageNamed:(NSString *)image selectedImageNamed:(NSString *)selectedImageNamed {
    return [[self class] buttonWithImage:[UIImage imageWithBundleImage:image] selectedImage:[UIImage imageWithBundleImage:selectedImageNamed]];
}

@end
