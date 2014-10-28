//
//  ViewController.h
//  TableExpansion
//
//  Created by Gagan Mishra on 10/28/14.
//  Copyright (c) 2014 Gagan_Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@class VideoCell;
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet VideoCell *objectVideoCell;
}
@property (weak, nonatomic) IBOutlet UITableView *animateTableView;


@end

