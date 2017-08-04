//
//  RoundedImageView.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "RoundedImageView.h"

@implementation RoundedImageView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.borderWidth = 0;
    self.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = self.frame.size.height;
    self.layer.cornerRadius = height/2;
}


- (void)removeRounding
{
    self.clipsToBounds = NO;
    self.layer.cornerRadius = 0;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
