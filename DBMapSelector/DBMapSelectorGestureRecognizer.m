//
//  DBMapSelectorGestureRecognizer.m
//  DBMapSelectorViewController
//
//  Created by Denis Bogatyrev on 28.03.15.
//
//  The MIT License (MIT)
//  Copyright (c) 2015 Denis Bogatyrev.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

@import UIKit.UIGestureRecognizerSubclass;
#import "DBMapSelectorGestureRecognizer.h"

NSNotificationName const DBMapSelectorCircleResizeDidBeginNotificationName = @"DBMapSelectorCircleResizeDidBegin";
NSNotificationName const DBMapSelectorCircleResizeDidEndNotificationName = @"DBMapSelectorCircleResizeDidEnd";
@implementation DBMapSelectorGestureRecognizer

@synthesize touchesBeganCallback;
@synthesize touchesMovedCallback;
@synthesize touchesEndedCallback;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cancelsTouchesInView = NO;
        self.delaysTouchesEnded = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (touchesBeganCallback) {
        touchesBeganCallback(touches, event);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if(touchesEndedCallback) {
        touchesEndedCallback(touches, event);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if(touchesMovedCallback) {
        touchesMovedCallback(touches, event);
    }
}
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}

@end
