//
//  COFriendsCell.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/7/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "COFriendsCell.h"
#import "constants.h"

@implementation COFriendsCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithHexString:kColorGreen];
    self.contentView.backgroundColor = [UIColor colorWithHexString:kColorGreen];
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.borderColor = [[UIColor colorWithHexString:kColorGreen] CGColor];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.profilePicImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.profilePicImageView.layer.borderWidth = 1;
    self.profilePicImageView.layer.cornerRadius = 30;
    self.profilePicImageView.clipsToBounds = YES;
    
    self.profileNameLabel.font = [UIFont fontWithName:kAltruusFont size:20];
    self.profileNameLabel.textColor = [UIColor whiteColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
