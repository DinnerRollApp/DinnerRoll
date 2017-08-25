//
// Created by Florian on 02/05/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


@import UIKit;


@class MHCardView;
@class MHPaneBehavior;


typedef NS_ENUM(NSInteger, MHPaneState) {
    MHPaneStateOpen,
    MHPaneStateClosed,
};


@interface MHMainViewController : UIViewController

@property (nonatomic, readonly) MHPaneState paneState;
@property (weak, nonatomic) IBOutlet MHCardView *pane;

@end
