//
// Created by Florian on 02/05/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MHMainViewController.h"
#import "MHPaneBehavior.h"
#import "MHDraggableView.h"


@interface MainViewController () <DraggableViewDelegate>

@property (nonatomic) PaneState paneState;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic, strong) PaneBehavior *paneBehavior;
@property (nonatomic) CGPoint startingPoint;

@end


@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.startingPoint = self.pane.center;
}

- (void)setup
{
    self.paneState = PaneStateClosed;
    self.pane.delegate = self;

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)animatePaneWithInitialVelocity:(CGPoint)initialVelocity
{
    if (!self.paneBehavior) {
        PaneBehavior *behavior = [[PaneBehavior alloc] initWithItem:self.pane];
        self.paneBehavior = behavior;
    }
    self.paneBehavior.targetPoint = self.targetPoint;
    self.paneBehavior.velocity = initialVelocity;
    [self.animator addBehavior:self.paneBehavior];
}

- (CGPoint)targetPoint
{
    return self.paneState == PaneStateClosed ? self.startingPoint : CGPointMake(self.view.center.x, self.view.center.y - 50);
}


#pragma mark DraggableViewDelegate

- (void)draggableView:(DraggableView *)view draggingEndedWithVelocity:(CGPoint)velocity lastTouchLocationInSuperview:(CGPoint)touch
{
    PaneState targetState;
    if(velocity.y < 0){
        targetState = PaneStateClosed;
    }
    else if(velocity.y > 0){
        targetState = PaneStateOpen;
    }
    else{
        targetState = touch.y <= self.view.frame.size.height / 8 ? PaneStateClosed : PaneStateOpen;
    }
    self.paneState = targetState;
    [self animatePaneWithInitialVelocity:velocity];
}

- (void)draggableViewBeganDragging:(DraggableView *)view
{
    [self.animator removeAllBehaviors];
}


#pragma mark Actions

- (void)didTap:(UITapGestureRecognizer *)tapRecognizer
{
    self.paneState = self.paneState == PaneStateOpen ? PaneStateClosed : PaneStateOpen;
    [self animatePaneWithInitialVelocity:self.paneBehavior.velocity];
}

@end
