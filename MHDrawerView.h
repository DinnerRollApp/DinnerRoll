//
// Created by Florian on 21/04/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


@import UIKit;


@class MHDrawerView;


@protocol MHDrawerViewDelegate

- (void)drawerView:(MHDrawerView *)view draggingEndedWithVelocity:(CGPoint)velocity lastTouchLocationInSuperview    :(CGPoint)touch;
- (void)MHDrawerViewBeganDragging:(MHDrawerView *)view;

@end

static NSNotificationName const MHCardDidDragNotificationName = @"MHCardDidDragNotification";

@interface MHDrawerView : UIView

@property (nonatomic, weak) id <MHDrawerViewDelegate> delegate;

@end
