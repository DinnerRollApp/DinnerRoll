//
// Created by Florian on 21/04/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


@import UIKit;


@class MHCardView;


@protocol MHCardViewDelegate

- (void)cardView:(MHCardView *)view draggingEndedWithVelocity:(CGPoint)velocity lastTouchLocationInSuperview    :(CGPoint)touch;
- (void)MHCardViewBeganDragging:(MHCardView *)view;

@end

static NSNotificationName const MHCardDidDragNotificationName = @"MHCardDidDragNotification";

@interface MHCardView : UIView

@property (nonatomic, weak) id <MHCardViewDelegate> delegate;

@end
