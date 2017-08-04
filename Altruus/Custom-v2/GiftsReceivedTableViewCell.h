//
//  GiftsTableViewCell.h
//  Altruus
//
//  Created by Alberto Rivera on 15/06/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftsReceivedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UIImageView *redeemImageview;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@end
