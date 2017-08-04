//
//  COPromoCell.m
//  Altruus
//
//  Created by CJ Ogbuehi on 5/19/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "COPromoCell.h"
#import "constants.h"
#import <MapKit/MapKit.h>

@interface COPromoCell()
@end

@implementation COPromoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            [((UILabel *)view) setTextColor:[UIColor colorWithHexString:kColorBlue]];
        }
    }
    
    self.expiresTitleLabel.text = NSLocalizedString(@"Expires:", nil);
    self.fromTitleLabel.text = NSLocalizedString(@"From:", nil);
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.6;
    
    self.titleLabel.font = [UIFont fontWithName:kAltruusFontBold size:18];
    self.expiresTitleLabel.font = [UIFont fontWithName:kAltruusFontBold size:15];
    self.fromTitleLabel.font = [UIFont fontWithName:kAltruusFontBold size:15];
    self.expiresLabel.font = [UIFont fontWithName:kAltruusFont size:16];
    self.fromLabel.font = [UIFont fontWithName:kAltruusFont size:16];
    self.addressTitleLabel.font = [UIFont fontWithName:kAltruusFontBold size:15];
    self.addressLabel.font = [UIFont fontWithName:kAltruusFont size:16];
    
    // address label needs to be link
    [self.addressLabel setTextColor:[UIColor blueColor]];
    self.addressLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAddressLabel:)];
    tap.numberOfTapsRequired = 1;
    [self.addressLabel addGestureRecognizer:tap];
    
    self.addressLabel.text = @"1203 Wilshire ct, Allen, TX";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithHexString:kColorYellow]];
    [self setSelectedBackgroundView:selectedBackgroundView];
}

- (void)tappedAddressLabel:(UITapGestureRecognizer *)sender {
    UILabel *addressLabel = (UILabel *)sender.view;

    if (self.delegate){
        [self.delegate promoCell:self
         tappedAddressWithString:addressLabel.text];
    }
}


/*
- (void)setFrame:(CGRect)frame {
    frame.origin.y += 4;
    frame.size.height -= 2 * 4;
    [super setFrame:frame];
}
 */
@end
