//
//  ViewController.m
//  Pong
//
//  Created by Jens Andersson on 3/4/13.
//  Copyright (c) 2013 Jens Andersson. All rights reserved.
//

#import "PongController.h"
#import <QuartzCore/QuartzCore.h>

#define STEP_DURATION 0.05
#define RESET_BALL_ANIMATION_DURATION 0.5f
#define MARGIN_WHERE_BALL_IS_LEAVING 40
#define CPU_SKILL 20

@interface PongController ()

@end

@implementation PongController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment to get a round ball. Looks cooler with square :)
    //self.ball.layer.cornerRadius = self.ball.frame.size.width / 2;
    
    [self resetBoardForNewRound];
    if (self.mode == kGameSinglePlayer) {
        // Start movement of the computer paddle
        [self moveComputerPaddle];
        
        //Disable panning of computer paddle
        [self.playerOne.superview setGestureRecognizers:@[]];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startGameTimer];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_gameTimer invalidate];
}

-(void)quitPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)startGameTimer
{
    [_gameTimer invalidate];
    _gameTimer = [NSTimer scheduledTimerWithTimeInterval:STEP_DURATION target:self selector:@selector(step:) userInfo:nil repeats:YES];
}

#pragma mark Game setup

/*
 * Some maths to calculate a new starting direction
 * By choosing mid left/right part of the unit circle
 *  we avoid getting straight up/down directions
 */
-(void)resetBallDirection
{
    float randomUnity = arc4random_uniform(100)/100.0;
    int horizontalDirection = (arc4random() % 2 ? 1 : -1);
    float angle = M_PI_4 + randomUnity * M_PI_2;
    float direction = horizontalDirection * angle;
    
    dirX = sin(direction);
    dirY = cos(direction);
}

-(void)resetBoardForNewRound
{
    speed = self.view.frame.size.width / 50.0;
    
    [self resetBallDirection];
    
    [_gameTimer invalidate];
    
    [UIView animateWithDuration:RESET_BALL_ANIMATION_DURATION animations:^{
        self.ball.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    } completion:^(BOOL finished){
        [self startGameTimer];
    }];
    
    [self enlargeAnimation:self.ball];
    
}

-(void)updatePlayerScoreLabels
{
    self.playerOneScoreLabel.text = [NSString stringWithFormat:@"%d",playerOneScore];
    self.playerTwoScoreLabel.text = [NSString stringWithFormat:@"%d",playerTwoScore];
}


#pragma mark Paddle handling
- (IBAction)paddlePanned:(UIPanGestureRecognizer*)recognizer {
    UIView *paddleWrapper = recognizer.view;
    UIView *paddle = [[paddleWrapper subviews] lastObject];
    switch([recognizer state]) {
        case UIGestureRecognizerStateBegan: {
            paddle.backgroundColor = UIColor.whiteColor;
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            CGPoint position = [recognizer locationInView:self.view];
            
            CGFloat haldPaddleHeight = paddleWrapper.frame.size.height / 2.0;
            
            CGPoint newCenter = paddleWrapper.center;
            newCenter.y = position.y;
            
            newCenter.y = MAX(haldPaddleHeight, newCenter.y);
            newCenter.y = MIN(self.view.bounds.size.height - haldPaddleHeight, newCenter.y);
            
            paddleWrapper.center = newCenter;
            
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            paddle.backgroundColor = UIColor.grayColor;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark Game loop

/*
 * Game loop
 *  - Moves the ball and checks for obstacles
 */
- (void)step:(NSTimer*)timer
{
    speed += 0.05;
    [self checkForBallLevingSide];
    
    CGPoint newCenter = self.ball.center;
    CGFloat ballRadius = self.ball.frame.size.height / 2.0;
    
    newCenter.x += dirX * speed;
    newCenter.y += dirY * speed;
    
    CGFloat upperEdge = ballRadius;
    CGFloat bottomEdge = self.view.bounds.size.height - ballRadius;
    
    // Bounce ball of top/bottom walls
    if (newCenter.y <= upperEdge) {
        dirY = ABS(dirY);
        newCenter.y = upperEdge;
    } else if (newCenter.y >= bottomEdge) {
        dirY = -ABS(dirY);
        newCenter.y = bottomEdge;
    }
    
    [UIView animateWithDuration:STEP_DURATION animations:^{
        self.ball.center = newCenter;
    }];
    
    
}

-(BOOL)didBallHitPaddle:(UIView *)paddle withinLimit:(CGFloat)limit
{
    if (CGRectIntersectsRect(paddle.frame, self.ball.frame)){
        [self deflectBallFromPaddle:paddle];
        CGRect ballFrame = self.ball.frame;
        ballFrame.origin.x = limit;
        self.ball.frame = ballFrame;
        return YES;
    } else
        return NO;
}

-(void)checkForBallLevingSide
{
    
    float limitLeft = MARGIN_WHERE_BALL_IS_LEAVING;
    float limitRight = self.view.bounds.size.width - self.ball.frame.size.width - MARGIN_WHERE_BALL_IS_LEAVING;
    
    CGRect ballFrame = self.ball.frame;
    CGFloat ballX = ballFrame.origin.x;
    
    if (ballX < limitLeft) {
        if (![self didBallHitPaddle:self.playerOne.superview withinLimit:limitLeft])
            [self playerDidMiss:kPlayerOne];
    }else if (ballX > limitRight) {
        if (![self didBallHitPaddle:self.playerTwo.superview withinLimit:limitRight])
            [self playerDidMiss:kPlayerTwo];
    }
    
    
}

/*
 * Calculates new dirX and dirY after the bounce.
 * The longer from the paddle's middle the bigger the result angle gets. (Pong style)
 */
-(void)deflectBallFromPaddle:(UIView *)paddle
{
    dirX *= -1;
    
    CGFloat diff = self.ball.center.y - paddle.center.y;
    float p = diff / paddle.frame.size.height * 2.0f;
    dirY += p * 0.5;
    
    
}


-(void)playerDidMiss:(kPlayer)player
{
    if (player == kPlayerOne) {
        playerTwoScore++;
        [self victoryShake:self.playerTwo];
        [self enlargeAnimation:self.playerTwoScoreLabel];
    }
    else if (player == kPlayerTwo) {
        playerOneScore++;
        [self victoryShake:self.playerOne];
        [self enlargeAnimation:self.playerOneScoreLabel];
    }
    
    [self resetBoardForNewRound];
    [self updatePlayerScoreLabels];
}

-(void)moveComputerPaddle
{
    UIView *paddle = self.playerOne.superview;
    CGPoint cpuCenter = paddle.center;
    CGFloat diff = self.ball.center.y - paddle.center.y;
    CGFloat movement = MIN(CPU_SKILL, ABS(diff));
    
    movement *= diff > 0 ? 1 : -1;
    
    cpuCenter.y += movement;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.playerOne.superview.center = cpuCenter;
    } completion:^(BOOL b) {
        [self moveComputerPaddle];
    }];
}

#pragma mark Animation
-(void)victoryShake:(UIView *)view
{
    CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
    anim.values = [ NSArray arrayWithObjects:
                   [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -20.0f, 0.0f) ],
                   [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 20.0f, 0.0f) ],
                   nil ] ;
    anim.autoreverses = YES ;
    anim.repeatCount = 4.0f ;
    anim.duration = 0.07f ;
    
    [view.layer addAnimation:anim forKey:nil];
}

-(void)enlargeAnimation:(UIView *)view
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3.0, 3.0, 1.0)];
    [animation setDuration:RESET_BALL_ANIMATION_DURATION * 0.5];
    animation.repeatCount = 1.0f ;
    [animation setAutoreverses:YES];
    
    [view.layer addAnimation:animation forKey:nil];
}

@end
