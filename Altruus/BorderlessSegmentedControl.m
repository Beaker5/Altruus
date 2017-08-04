//
//  BorderlessSegmentedControl.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "BorderlessSegmentedControl.h"
#import "constants.h"

@implementation BorderlessSegmentedControl


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self removeBorders];
}


- (void)removeBorders
{
    UIColor *bgColor = [UIColor altruus_veryLightBlueColor];
    UIColor *bgColor2 = [UIColor altruus_darkSkyBlueColor];
    
    NSDictionary *titleBlueDict = @{NSForegroundColorAttributeName:bgColor2,NSFontAttributeName:[UIFont altruus_menuSemiBoldFont]};
    NSDictionary *titleGreyDict = @{NSForegroundColorAttributeName:[UIColor altruus_bluegreyTwoColor],NSFontAttributeName:[UIFont altruus_menuSemiBoldFont]};
    
    [self setBackgroundImage:[self imageWithColor:bgColor] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[self imageWithColor:bgColor] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setTitleTextAttributes:titleBlueDict forState:UIControlStateSelected];
    [self setTitleTextAttributes:titleGreyDict forState:UIControlStateNormal];
    [self setDividerImage:[self imageWithColor:[UIColor clearColor]] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
