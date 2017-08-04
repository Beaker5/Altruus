//
//  PageItemViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/13/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageItemViewController : UIViewController

// Item controller information
@property (nonatomic) NSUInteger itemIndex;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *messageString;
@property (nonatomic, strong) NSString *videoString;

@end
