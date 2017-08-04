//
//  GiftsTableViewCell.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 6/21/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *merchantImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *categroyLabel;

@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
@property (weak, nonatomic) IBOutlet UILabel *heartLikesLabel;

@end
