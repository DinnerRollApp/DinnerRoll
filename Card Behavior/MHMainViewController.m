//
// Created by Florian on 02/05/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MHMainViewController.h"
#import "MHPaneBehavior.h"
#import "MHCardView.h"


@interface MHMainViewController () <MHCardViewDelegate>

@property (nonatomic, readwrite) MHPaneState paneState;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic, strong) MHPaneBehavior *paneBehavior;
@property (nonatomic) CGPoint startingPoint;

-(void)togglePaneState;

@end


@implementation MHMainViewController

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
    self.paneState = MHPaneStateClosed;
    self.pane.delegate = self;

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePaneState)];
    doubleTap.numberOfTapsRequired = 2;
    [self.pane addGestureRecognizer:doubleTap];


    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    __weak typeof(self) me = self;
    self.paneBehavior.action = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MHCardDidDragNotificationName object:me];
    };
}

- (void)animatePaneWithInitialVelocity:(CGPoint)initialVelocity
{
    if (!self.paneBehavior) {
        MHPaneBehavior *behavior = [[MHPaneBehavior alloc] initWithItem:self.pane];
        self.paneBehavior = behavior;
    }
    self.paneBehavior.targetPoint = self.targetPoint;
    self.paneBehavior.velocity = initialVelocity;
    [self.animator addBehavior:self.paneBehavior];
}

- (CGPoint)targetPoint
{
    return self.paneState == MHPaneStateClosed ? self.startingPoint : CGPointMake(self.view.center.x, self.view.center.y + 50);
}

-(void)setPaneState:(MHPaneState)state withInitialVelocity:(CGPoint)velocity{
    self.paneState = state;
    [self animatePaneWithInitialVelocity:velocity];
}
#pragma mark MHCardViewDelegate

- (void)cardView:(MHCardView *)view draggingEndedWithVelocity:(CGPoint)velocity lastTouchLocationInSuperview:(CGPoint)touch
{
    MHPaneState targetState;
    if(velocity.y > 0){
        targetState = MHPaneStateClosed;
    }
    else if(velocity.y < 0){
        targetState = MHPaneStateOpen;
    }
    else{
        targetState = touch.y >= self.view.frame.size.height / 8 ? MHPaneStateClosed : MHPaneStateOpen;
    }
    [self setPaneState:targetState withInitialVelocity:velocity];
}

- (void)MHCardViewBeganDragging:(MHCardView *)view
{
    [self.animator removeAllBehaviors];
}


#pragma mark Actions

-(void)togglePaneState{
    [self setPaneState:self.paneState == MHPaneStateOpen ? MHPaneStateClosed : MHPaneStateOpen withInitialVelocity:self.paneBehavior.velocity];
}

@end
