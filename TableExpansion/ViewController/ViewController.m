//
//  ViewController.m
//  TableExpansion
//
//  Created by Gagan Mishra on 10/28/14.
//  Copyright (c) 2014 Gagan_Work. All rights reserved.
//

#import "ViewController.h"
#import "VideoCell.h"
@interface ViewController ()
{
    NSIndexPath *selectedIndexPath;
    BOOL fullvisible;
    long index;
    BOOL isScrolling;
    AVPlayerItem *tempPlayer;
    UIActivityIndicatorView *activity;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSBundle mainBundle]loadNibNamed:@"ViewController" owner:self options:nil];
    activity=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.hidesWhenStopped=YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-TableView Delehgate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"Cell";
    VideoCell *cell=(VideoCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
    {
        [[NSBundle mainBundle]loadNibNamed:@"VideoCell" owner:self options:nil];
        cell=objectVideoCell;
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    NSString *videoURLStr=nil;
    switch (indexPath.row%4) {
        case 0:
            videoURLStr=@"http://archive.org/download/WaltDisneyCartoons-MickeyMouseMinnieMouseDonaldDuckGoofyAndPluto/WaltDisneyCartoons-MickeyMouseMinnieMouseDonaldDuckGoofyAndPluto-HawaiianHoliday1937-Video.mp4";//[[NSBundle mainBundle]pathForResource:@"video_1" ofType:@"mp4"];
            break;
        case 1:
            videoURLStr=@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8";//[[NSBundle mainBundle]pathForResource:@"video_2" ofType:@"mp4"];
            break;
        case 2:
            videoURLStr=@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8";//[[NSBundle mainBundle]pathForResource:@"video_3" ofType:@"mp4"];
            break;
        case 3:
            break;
        default:
            break;
    }
     if (fullvisible && index == indexPath.row)
    {
        if (!isScrolling) {
            NSURL *url = [NSURL URLWithString:videoURLStr];//[NSURL fileURLWithPath:videoURLStr];
            if(!url)
            {
                 videoURLStr=[[NSBundle mainBundle]pathForResource:@"video_4" ofType:@"mp4"];
                url=[NSURL fileURLWithPath:videoURLStr];
            }
            cell.videoItem = [AVPlayerItem playerItemWithURL:url];
            cell.videoPlayer = [AVPlayer playerWithPlayerItem:cell.videoItem];
            cell.avLayer = [AVPlayerLayer playerLayerWithPlayer:cell.videoPlayer];
            cell.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [cell.videoItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
            [cell.videoItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidBufferPlaying:) name:AVPlayerItemPlaybackStalledNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            cell.avLayer.frame = cell.frame;// CGRectMake(5, 9, 310, 310);
            [cell.contentView.layer addSublayer:cell.avLayer];
            [cell.videoPlayer play];
            tempPlayer=cell.videoItem;
            //            isScrolling=NO;
            activity.center=cell.center;
            [activity startAnimating];
           [cell.contentView addSubview:activity];
        }
    }
    else
    {
        [cell.avLayer removeFromSuperlayer];
         cell.videoItem = nil;
        [cell.videoPlayer pause];
         cell.videoPlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [activity stopAnimating];
    if ( [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        
    }
    else if ( [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
    }
}

-(void)itemDidBufferPlaying:(id)object
{
    NSLog(@"Buffering");
}

-(void)itemDidFinishPlaying:(id)object
{
    NSLog(@"Finishing");
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrolling = NO;
    NSArray* cells = self.animateTableView.visibleCells;
    for (VideoCell* cell in cells)
    {
        if (cell.frame.origin.y > scrollView.contentOffset.y &&cell.frame.origin.y + cell.frame.size.height < scrollView.contentOffset.y +[UIScreen mainScreen].bounds.size.height)
        {
            NSIndexPath *path = [self.animateTableView indexPathForCell:cell] ;
            index = path.row;
            fullvisible = YES;
            [self.animateTableView reloadData];
            break;
        }
        else
        {
            fullvisible = NO;
        }
    }
    //    [self.animateTableView reloadData];
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    if(tempPlayer)
    {
        [tempPlayer removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [tempPlayer removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        tempPlayer=nil;
    }
    isScrolling = YES;
    [self.animateTableView reloadData];
    index = -1;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    //    NSArray* cells = self.animateTableView.visibleCells;
    //    for (VideoCell* cell in cells)
    //    {
    //        if (cell.frame.origin.y > 30 &&cell.frame.origin.y + cell.frame.size.height < 30 +[UIScreen mainScreen].bounds.size.height)
    //        {
    //            NSIndexPath *path = [self.animateTableView indexPathForCell:cell] ;
    //            index = path.row;
    //            fullvisible = YES;
    //            [self.animateTableView reloadData];
    //        }
    //        else
    //        {
    //            fullvisible = NO;
    //        }
    //    }
}

- (BOOL)isIndexPathVisible:(NSIndexPath*)indexPath
{
    NSArray *visiblePaths = [self.animateTableView indexPathsForVisibleRows];
    for (NSIndexPath *currentIndex in visiblePaths)
    {
        NSComparisonResult result = [currentIndex compare:currentIndex];
        
        if(result == NSOrderedSame)
        {
            NSLog(@"Visible");
            return YES;
        }
    }
    return NO;
}

/*
 -(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
 
 if(selectedIndexPath)
 {
 selectedIndexPath=nil;
 //        for(UIView *view in cell.subviews)
 //        {
 //            if([view isKindOfClass:[UIView class]])
 //            {
 //                [view removeFromSuperview];
 //            }
 //        }
 //        [self.animateTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
 [tableView reloadData];
 }
 selectedIndexPath=indexPath;
 [self performSelector:@selector(ExpandCellAtCell:) withObject:cell];
 }
 */

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320;
}

-(void)ExpandCellAtCell:(UITableViewCell*)cell
{
    [self.animateTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [UIView transitionWithView:cell duration:0.5 options:UIViewAnimationOptionAutoreverse animations:^{
    } completion:^(BOOL finished) {
        cell.frame=CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 88);
    }];
}

@end
