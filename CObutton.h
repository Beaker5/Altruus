//
//  CObutton.h
//  Altruus
//
//  Created by CJ Ogbuehi on 3/30/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CObutton : UIButton

@property (nonatomic, assign)CGFloat cornerRadius;
@property (nonatomic, strong)UIColor *backgroundColor;
@property (nonatomic, strong)UIColor *textColor;
@property (nonatomic, strong)NSString *text;
@property (nonatomic)BOOL small;

@end
