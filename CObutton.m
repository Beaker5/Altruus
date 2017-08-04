//
//  CObutton.m
//  Altruus
//
//  Created by CJ Ogbuehi on 3/30/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "CObutton.h"
#import "constants.h"

@implementation CObutton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self layoutStyle];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
     
        //[self layoutStyle];
    }
    return self;
}


- (CGSize)intrinsicContentSize
{
    if (self.small){
        return CGSizeMake(115, 40);
    }
    
    CGSize original = [super intrinsicContentSize];
    if (original.width < 210){
        return CGSizeMake(210, 40);
    }
    else{
        return CGSizeMake(original.width + 60, original.height + 15);
    }
}


- (void)layoutStyle
{
    //self.contentEdgeInsets = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0);
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.layer.backgroundColor = [[UIColor colorWithHexString:kColorGreen] CGColor];
    self.layer.cornerRadius = 6.0;

    self.titleLabel.text = @"add localized string";
}

/*
- (void)prepareForInterfaceBuilder
{
    [self layoutStyle];
}
*/

#pragma -mark Setters

- (void)setText:(NSString *)text
{
    _text = text;
    self.titleLabel.text = NSLocalizedString(text, nil);
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.titleLabel.textColor = textColor;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.layer.backgroundColor = [backgroundColor CGColor];
}
@end
