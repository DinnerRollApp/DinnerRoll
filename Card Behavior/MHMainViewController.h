//
// Created by Florian on 02/05/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


@import UIKit;


@class MHCardView;
@class MHPaneBehavior;


typedef NS_CLOSED_ENUM(NSInteger, MHPaneState) {
    MHPaneStateOpen,
    MHPaneStateClosed,
};


@interface MHMainViewController : UIViewController
@property (nonatomic, readonly) MHPaneState paneState;
@property (nonatomic) CGRect cardClosedFrame;
@property (nonatomic) CGRect cardOpenFrame;
@property (weak, nonatomic) IBOutlet MHCardView *pane;
-(void)setPaneState:(MHPaneState)state withInitialVelocity:(CGPoint)velocity;
@end
