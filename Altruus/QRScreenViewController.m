//
//  QRScreenViewController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/19/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "QRScreenViewController.h"
#import "PromoteViewController.h"
#import "constants.h"
#import "SlideNavigationController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <AVFoundation/AVFoundation.h>

@interface QRScreenViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *qrContainerView;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;

@property (nonatomic) BOOL presentedNextScreen;
@end

@implementation QRScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.screenType == QRScreenTypeGift){
        self.navigationItem.title = NSLocalizedString(@"Gift Friends!", nil);
    }
    else if (self.screenType == QRScreenTypeRedeem){
        self.navigationItem.title = NSLocalizedString(@"Redeem Gifts!", nil);
    }
    else{
        self.navigationItem.title = @"Need to set";
    }
    
    [self setup];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if no code show scanner to grab code
    if (!self.qrString){
        [self checkPermission];
        [self startQRScanner];
    }
    
    [self qrCheck];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.captureDevice hasTorch]){
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice setTorchMode:AVCaptureTorchModeOff];  
        [self.captureDevice unlockForConfiguration];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setup
{
    self.displayLabel.textColor = [UIColor whiteColor];
    self.displayLabel.text = NSLocalizedString(@"Loading QR Scanner...", nil);
    self.view.backgroundColor = [UIColor colorWithHexString:kColorBlue];
    
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:50];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(50, 50)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    

    
}

- (void)qrCheck
{
    // if we have temp string no need to scan
    if (self.qrString){
        [self nextScreenWithString:self.qrString];
    }
}

- (void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)checkPermission
{
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized){
        // Gave camera permisson
        return;
        
    }
    else{
        // Didnt give permission
        // So request it
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (granted){
                                         return;
                                     }
                                     else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self showMessageWithTitle:NSLocalizedString(@"Error", nil)
                                                             andMessage:NSLocalizedString(@"Altruus must have permission to use your camera to scan QR codes. Give access in settings please.", nil)];
                                             return;
                                         });
                                     }
                                 }];
    }

}


-(void)startQRScanner
{
    
    NSError *error;
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if (!input){
        DLog(@"error %@",error.localizedDescription);
        [self showMessageWithTitle:NSLocalizedString(@"Error", nil)
                        andMessage:error.localizedDescription];
        return;
    }
    
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.qrContainerView.layer.bounds];
    [self.qrContainerView.layer addSublayer:self.videoPreviewLayer];
    
    
    [self.captureSession startRunning];
    
    //add torch if available
    if ([self.captureDevice hasTorch]){
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice setTorchMode:AVCaptureTorchModeOn];  // use AVCaptureTorchModeOff to turn off
        [self.captureDevice unlockForConfiguration];
    }
    
    self.displayLabel.text = NSLocalizedString(@"Scanning...", nil);
}

- (void)nextScreenWithString:(NSString *)string
{

    // need this so it only presents next screen once
    if (!self.presentedNextScreen){
        self.displayLabel.text = NSLocalizedString(@"Code Detected!", nil);
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardPromoteScreen];
        if ([controller isKindOfClass:[PromoteViewController class]]){
            ((PromoteViewController *)controller).localUser = self.localUser;
            ((PromoteViewController *)controller).qrString = string;
        }
        else{
            DLog(@"CONTROLLER IS NOT PROMOTE SCREEN!")
            return;
        }
        
        
        [self.navigationController pushViewController:controller animated:YES];
    }

}


#pragma mark AVCapture delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil &&[metadataObjects count] > 0){
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]){
            NSString *qrValue = [metadataObj stringValue];
            DLog(@"Qr code is %@",qrValue);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.captureSession stopRunning];
                [self.videoPreviewLayer removeFromSuperlayer];
                self.captureSession = nil;
                self.videoPreviewLayer = nil;
                
                [self nextScreenWithString:qrValue];
                // need this so it only presents next screen once
                self.presentedNextScreen = YES;

            });
        }
    }
}
#pragma mark Helpers

-(void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil];
    [alert show];
}

@end
