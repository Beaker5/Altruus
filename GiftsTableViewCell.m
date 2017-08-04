//
//  GiftsTableViewCell.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 6/21/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "GiftsTableViewCell.h"
#import "UIColor+ALTRUUSAdditions.h"

@implementation GiftsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.heartLikesLabel.textColor = [UIColor altruus_barbiePinkColor];
    
}



@end
