//
//  OrgTableViewCell.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "OrgTableViewCell.h"

@implementation OrgTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)setScreenType:(ScreenType)screenType
{
    _screenType = screenType;
    
    if (screenType == ScreenTypeFriends){
        self.distanceTitleLabel.text = NSLocalizedString(@"BIRTHDAY", nil);
        
    }
    else if (screenType == ScreenTypeOrganization){
        self.distanceTitleLabel.text = NSLocalizedString(@"DISTANCE", nil);
    }
}

@end
