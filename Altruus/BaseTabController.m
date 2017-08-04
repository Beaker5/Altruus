//
//  BaseTabController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 6/24/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "BaseTabController.h"
#import "UIColor+ALTRUUSAdditions.h"
#import "constants.h"

@interface BaseTabController ()

@end

@implementation BaseTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Do this to get tabs right
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        for (UITabBarItem *tbi in self.tabBar.items) {
            tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            tbi.selectedImage = [tbi.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    
    [self setup];
    
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = 80;
    tabFrame.origin.y = self.view.frame.size.height - 80;
    self.tabBar.frame = tabFrame;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    
    [self.tabBar setValue:@(YES) forKey:@"_hidesShadow"];
    self.selectedIndex = 2;
    
    self.tabBar.layer.borderWidth = 0.20;
    self.tabBar.layer.borderColor = [[UIColor altruus_bluegreyTwoColor] CGColor];
    self.tabBar.clipsToBounds = YES;
    
    
    
    
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
