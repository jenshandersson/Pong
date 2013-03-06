//
//  ViewController.h
//  Pong
//
//  Created by Jens Andersson on 3/4/13.
//  Copyright (c) 2013 Jens Andersson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PongController : UIViewController {
    NSTimer *_gameTimer;
    CGFloat dirX, dirY, speed;
    int playerOneScore, playerTwoScore;
}

typedef enum {
	kPlayerOne = 1,
	kPlayerTwo,
} kPlayer;

typedef enum {
    kGameSinglePlayer = 0,
    kGameMultiPlayer,
} kGameMode;

@property (nonatomic) IBOutlet UIView *playerOne;
@property (nonatomic) IBOutlet UIView *playerTwo;
@property (nonatomic) IBOutlet UIView *ball;
@property (weak, nonatomic) IBOutlet UILabel *playerOneScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerTwoScoreLabel;
@property (nonatomic) kGameMode mode;

- (IBAction)paddlePanned:(UIPanGestureRecognizer*)recognizer;
- (IBAction)quitPressed:(id)sender;
    
@end

