//
//  VideoCell.h
//  TableExpansion
//
//  Created by Gagan Mishra on 10/28/14.
//  Copyright (c) 2014 Gagan_Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoCell : UITableViewCell
@property(nonatomic,strong)AVPlayer *videoPlayer;
@property(nonatomic, strong)AVPlayerLayer  *avLayer;
@property(nonatomic,strong)AVPlayerItem  *videoItem;
@property (weak, nonatomic) IBOutlet UIImageView *thumbNailImageView;
@end
