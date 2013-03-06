//
//  RootViewController.m
//  Pong
//
//  Created by Jens Andersson on 3/5/13.
//  Copyright (c) 2013 Jens Andersson. All rights reserved.
//

#import "ChooseGameController.h"
#import "PongController.h"

@interface ChooseGameController ()

@end

@implementation ChooseGameController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PongController *vc = (PongController *)segue.destinationViewController;
    BOOL isMultiplayer = [segue.identifier isEqualToString:@"multiPlayer"];
    vc.mode = isMultiplayer ? kGameMultiPlayer : kGameSinglePlayer;
}

@end
