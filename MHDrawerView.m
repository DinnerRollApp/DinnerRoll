//
// Created by Florian on 21/04/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MHDrawerView.h"


@implementation MHDrawerView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self addGestureRecognizer:recognizer];
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self.superview];
    self.center = CGPointMake(self.center.x, self.center.y + point.y);
    [recognizer setTranslation:CGPointZero inView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.superview];
        velocity.x = 0;
        [self.delegate drawerView:self draggingEndedWithVelocity:velocity lastTouchLocationInSuperview:point];
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate MHDrawerViewBeganDragging:self];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:MHCardDidDragNotificationName object:self];
}

@end
