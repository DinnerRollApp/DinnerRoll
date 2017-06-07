//
// Created by Florian on 21/04/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


@import UIKit;


@class DraggableView;


@protocol DraggableViewDelegate

- (void)draggableView:(DraggableView *)view draggingEndedWithVelocity:(CGPoint)velocity lastTouchLocationInSuperview    :(CGPoint)touch;
- (void)draggableViewBeganDragging:(DraggableView *)view;

@end

static NSNotificationName const MHCardDidDragNotificationName = @"MHCardDidDragNotification";

@interface DraggableView : UIView

@property (nonatomic, weak) id <DraggableViewDelegate> delegate;

@end
