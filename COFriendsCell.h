//
//  COFriendsCell.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/7/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COLabel.h"

@interface COFriendsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet COLabel *profileNameLabel;

@end
