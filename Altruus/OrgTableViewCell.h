//
//  OrgTableViewCell.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, ScreenType)
{
    ScreenTypeFriends,
    ScreenTypeOrganization,
};


@interface OrgTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *orgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *altruusName;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTitleLabel;


@property (assign, nonatomic) ScreenType screenType;


@end
