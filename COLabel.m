//
//  COLabel.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/22/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "COLabel.h"

@implementation COLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setBounds:(CGRect)bounds {
    if (bounds.size.width != self.bounds.size.width) {
        [self setNeedsUpdateConstraints];
    }
    [super setBounds:bounds];
}

- (void)updateConstraints {
    if (self.preferredMaxLayoutWidth != self.bounds.size.width) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
    }
    
    [super updateConstraints];
}

@end
