//
// Created by Florian on 02/05/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


@import UIKit;


@class DraggableView;
@class PaneBehavior;


typedef NS_ENUM(NSInteger, PaneState) {
    PaneStateOpen,
    PaneStateClosed,
};


@interface MainViewController : UIViewController

@property (nonatomic, readonly) PaneState paneState;
@property (weak, nonatomic) IBOutlet DraggableView *pane;

@end
