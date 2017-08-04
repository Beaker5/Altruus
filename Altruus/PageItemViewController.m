//
//  PageItemViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/13/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "PageItemViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "constants.h"

@interface PageItemViewController ()

@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong,nonatomic) AVPlayer *avPlayer;
@property (strong,nonatomic) AVPlayerLayer *avPlayerLayer;

@end

@implementation PageItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = self.titleString;
    self.messageLabel.text = self.messageString;
    
    self.titleLabel.hidden = YES;
    self.titleLabel.alpha = 0;
    self.messageLabel.hidden = YES;
    self.messageLabel.alpha = 0;
    
    self.doneButton.layer.cornerRadius = 10;
    
    if (self.itemIndex != 2){
        self.doneButton.hidden = YES;
    }
    else{
        self.doneButton.hidden = NO;
    }
    
    // needs to be in view did load
    self.topContainerView.backgroundColor = [UIColor whiteColor];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.titleLabel.hidden = YES;
    self.titleLabel.alpha = 0;
    self.messageLabel.hidden = YES;
    self.messageLabel.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addAnimation];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:1
                     animations:^{
                         self.titleLabel.alpha = 1;
                         self.titleLabel.hidden = NO;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                          animations:^{
                                              self.messageLabel.alpha = 1;
                                              self.messageLabel.hidden = NO;
                                          }];
                     }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)addAnimation
{
    self.avPlayer = nil;
    [self.avPlayerLayer removeFromSuperlayer];
    
    
    NSString *pathVideo = [[NSBundle mainBundle] pathForResource:self.videoString ofType:@"mov"];
    NSURL *movieURL = [NSURL fileURLWithPath:pathVideo];
    
    self.avPlayer = [AVPlayer playerWithURL:movieURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    int x = 35;
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5){
        x = 15;
    }
    
    self.avPlayerLayer.frame = CGRectMake(x, 0, 300, 300);
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    self.avPlayerLayer.backgroundColor = [[UIColor clearColor] CGColor];
    
    [self.topContainerView.layer addSublayer:self.avPlayerLayer];
    
    [self.avPlayer play];
}



- (IBAction)tappedDone:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        // im being presented on a holder controller so dismiss that one next
        [[NSNotificationCenter defaultCenter] postNotificationName:kV2NotificationIntroScreenDone object:nil];
    }];
    
}


- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    self.titleLabel.text = _titleString;
}

- (void)setMessageString:(NSString *)messageString
{
    _messageString = messageString;
    self.messageLabel.text = _messageString;
}



@end
