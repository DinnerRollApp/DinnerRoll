//
// Created by Florian on 02/05/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MHMainViewController.h"
#import "MHPaneBehavior.h"
#import "MHCardView.h"


@interface MHMainViewController () <MHCardViewDelegate>

@property (nonatomic) PaneState paneState;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic, strong) MHPaneBehavior *MHPaneBehavior;
@property (nonatomic) CGPoint startingPoint;

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

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    __weak typeof(self) me = self;
    self.MHPaneBehavior.action = ^{
        //NSLog(@"Action executed");
        [[NSNotificationCenter defaultCenter] postNotificationName:MHCardDidDragNotificationName object:me];
    };
}

- (void)animatePaneWithInitialVelocity:(CGPoint)initialVelocity
{
    if (!self.MHPaneBehavior) {
        MHPaneBehavior *behavior = [[MHPaneBehavior alloc] initWithItem:self.pane];
        self.MHPaneBehavior = behavior;
    }
    self.MHPaneBehavior.targetPoint = self.targetPoint;
    self.MHPaneBehavior.velocity = initialVelocity;
    [self.animator addBehavior:self.MHPaneBehavior];
}

- (CGPoint)targetPoint
{
    return self.paneState == MHPaneStateClosed ? self.startingPoint : CGPointMake(self.view.center.x, self.view.center.y + 50);
}


#pragma mark MHCardViewDelegate

- (void)cardView:(MHCardView *)view draggingEndedWithVelocity:(CGPoint)velocity lastTouchLocationInSuperview:(CGPoint)touch
{
    PaneState targetState;
    if(velocity.y > 0){
        targetState = MHPaneStateClosed;
    }
    else if(velocity.y < 0){
        targetState = MHPaneStateOpen;
    }
    else{
        targetState = touch.y >= self.view.frame.size.height / 8 ? MHPaneStateClosed : MHPaneStateOpen;
    }
    self.paneState = targetState;
    [self animatePaneWithInitialVelocity:velocity];
}

- (void)MHCardViewBeganDragging:(MHCardView *)view
{
    [self.animator removeAllBehaviors];
}


#pragma mark Actions

- (void)didTap:(UITapGestureRecognizer *)tapRecognizer
{
    self.paneState = self.paneState == MHPaneStateOpen ? MHPaneStateClosed : MHPaneStateOpen;
    [self animatePaneWithInitialVelocity:self.MHPaneBehavior.velocity];
}

@end
