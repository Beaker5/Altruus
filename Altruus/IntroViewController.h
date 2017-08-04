//
//  IntroViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/14/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController<UIPageViewControllerDataSource>


@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSArray *introTitles;
@property (nonatomic,strong) NSArray *introMessages;
@property (nonatomic,strong) NSArray *introVideos;

@end
