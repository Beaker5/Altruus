//
//  IntroViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/14/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "IntroViewController.h"
#import "PageItemViewController.h"
#import "constants.h"

@interface IntroViewController ()

@property (assign) BOOL showingIntro;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self listenForNotifs];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.showingIntro){
        [self createPageViewController];
        [self setupPageControl];
        self.showingIntro = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)listenForNotifs
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(close)
                                                 name:kV2NotificationIntroScreenDone object:nil];
    
    
    
}


- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Page Indicator

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.introTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma -mark pageControl Datasource


- (void)createPageViewController
{
    self.introTitles = @[NSLocalizedString(@"Send gifts to your friends", nil),
                         NSLocalizedString(@"Receive gifts from your friends", nil),
                         NSLocalizedString(@"Donate gifts to charity", nil)];
    
    self.introMessages = @[NSLocalizedString(@"Choose free or paid gifts based on your location and send them to your friends and family.", nil),
                           NSLocalizedString(@"Present your redemption code at the business and get your gift!", nil),
                           NSLocalizedString(@"If you are unable to redeem your gift, you can choose to donate it to a local charity.", nil)];
    
    self.introVideos = @[@"onboard-1",@"onboard-2",@"onboard-3"];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
    UIPageViewController *pageController = [storyboard instantiateViewControllerWithIdentifier:@"introPageController"];
    pageController.dataSource = self;
    
    if([self.introTitles count])
    {
        NSArray *startingViewControllers = @[[self itemControllerForIndex:0]];
        [pageController setViewControllers:startingViewControllers
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:nil];
    }
    
    self.pageViewController = pageController;
    
    [self presentViewController:pageController animated:NO completion:nil];
    
    //[self addChildViewController:self.pageViewController];
    //[self.view addSubview:self.pageViewController.view];
    //[self.pageViewController didMoveToParentViewController:self];
}

- (void)setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[UIColor altruus_darkSkyBlueColor]];
    [[UIPageControl appearance] setBackgroundColor:[UIColor whiteColor]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PageItemViewController *itemController = (PageItemViewController *)viewController;
    
    if (itemController.itemIndex > 0)
    {
        return [self itemControllerForIndex:itemController.itemIndex-1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PageItemViewController *itemController = (PageItemViewController *)viewController;
    
    if (itemController.itemIndex+1 < [self.introTitles count])
    {
        return [self itemControllerForIndex:itemController.itemIndex+1];
    }
    
    return nil;
}

- (PageItemViewController *)itemControllerForIndex:(NSUInteger)itemIndex
{
    if (itemIndex < [self.introTitles count])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
        PageItemViewController *pageItemController = [storyboard instantiateViewControllerWithIdentifier:@"introItemController"];
        pageItemController.itemIndex = itemIndex;
        pageItemController.titleString = self.introTitles[itemIndex];
        pageItemController.messageString = self.introMessages[itemIndex];
        pageItemController.videoString = self.introVideos[itemIndex];
        
        return pageItemController;
    }
    
    return nil;
}


@end
