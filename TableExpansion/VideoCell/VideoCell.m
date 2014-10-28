//
//  VideoCell.m
//  TableExpansion
//
//  Created by Gagan Mishra on 10/28/14.
//  Copyright (c) 2014 Gagan_Work. All rights reserved.
//

#import "VideoCell.h"

@interface VideoCell ()

@end

@implementation VideoCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
