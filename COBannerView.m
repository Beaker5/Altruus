//
//  COBannerView.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/20/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "COBannerView.h"
#import "constants.h"

@implementation COBannerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.topView = [[UIView alloc] init];
        self.bottomView = [[UIView alloc] init];
        self.topView.backgroundColor = [UIColor colorWithHexString:kColorYellow];
        self.bottomView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithHexString:kColorGreen];
        
        
    }
    
    return self;
}

-(void)layoutSubviews
{
    
    CGRect mySize = self.bounds;
    self.topView.frame = CGRectMake(0, 0, mySize.size.width, 5);
    self.bottomView.frame = CGRectMake(0, mySize.size.height-5, mySize.size.width, 5);
    [self addSubview:self.bottomView];
    [self addSubview:self.topView];
    
    [super layoutSubviews];
    
    
}

-(void)setBgColor:(UIColor *)bgColor
{
    self.backgroundColor = bgColor;
}

-(void)setTopColor:(UIColor *)topColor
{
    self.topView.backgroundColor = topColor;
}



@end
