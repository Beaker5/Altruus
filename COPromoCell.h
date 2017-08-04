//
//  COPromoCell.h
//  Altruus
//
//  Created by CJ Ogbuehi on 5/19/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class COPromoCell;

@protocol COPromoCellDelegate <NSObject>

-(void)promoCell:(COPromoCell *)cell tappedAddressWithString:(NSString *)string;

@end

@interface COPromoCell : UITableViewCell

@property (weak,nonatomic) id<COPromoCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiresTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *fromTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiresLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end
