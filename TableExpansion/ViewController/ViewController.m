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
    NSMutableDictionary *dictOfImages;    //Use this Dictionary for avoiding Extra loading of images from URL
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSBundle mainBundle]loadNibNamed:@"ViewController" owner:self options:nil];
    activity=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.hidesWhenStopped=YES;
    // Do any additional setup after loading the view, typically from a nib.
    dictOfImages=[NSMutableDictionary dictionary];
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
            [cell.thumbNailImageView removeFromSuperview];
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
        NSURL *url = [NSURL URLWithString:videoURLStr];//[NSURL fileURLWithPath:videoURLStr];
        if(!url)
        {
            videoURLStr=[[NSBundle mainBundle]pathForResource:@"video_4" ofType:@"mp4"];
            url=[NSURL fileURLWithPath:videoURLStr];
        }
        //Pass your local video URL or Thumbnail Image URL for showing thumbnail
        NSArray *arr = [[NSArray alloc] initWithObjects:url,indexPath, nil];
        [self performSelectorInBackground:@selector(loadImageInBackground:) withObject:arr];
        [cell.avLayer removeFromSuperlayer];
        cell.videoItem = nil;
        [cell.videoPlayer pause];
        cell.videoPlayer = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) loadImageInBackground:(NSArray *)urlAndTagReference
{
    //------------------------------------------Uncomment Below code if you are using Local Video Files--------------------------------------------------------------------
    /*
     NSURL *imgUrl=[urlAndTagReference objectAtIndex:0];
     dispatch_queue_t  imageQueue_ = dispatch_queue_create("com.aequor.app.imageQueue", NULL);
     dispatch_async(imageQueue_, ^{
     // AVAssetImageGenerator
     AVAsset *asset = [[AVURLAsset alloc] initWithURL:imgUrl options:nil];;
     AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
     imageGenerator.appliesPreferredTrackTransform = YES;
     // calc midpoint time of video
     Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
     CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
     // get the image from
     NSError *error = nil;
     CMTime actualTime;
     CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
     UIImage *img= [[UIImage alloc] initWithCGImage:halfWayImage];
     dispatch_async(dispatch_get_main_queue(), ^{
     VideoCell *cell = (VideoCell*)[self.animateTableView cellForRowAtIndexPath:[urlAndTagReference objectAtIndex:1]];
     cell.thumbNailImageView.image=img;
     });
     });
     */
    
    //------------------------------------------Below code if you are using thumbnail URL for Video Files--------------------------------------------------------------------
    NSURL *imgURL=[NSURL URLWithString:@"http://pagead2.googlesyndication.com/simgad/8447710804836610390"];  //Pass Your Thumbnail URL
    VideoCell *cell = (VideoCell*)[self.animateTableView cellForRowAtIndexPath:[urlAndTagReference objectAtIndex:1]];
    if([dictOfImages objectForKey:imgURL]!=nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
           cell.thumbNailImageView.image=(UIImage*)[dictOfImages objectForKey:imgURL];
        });
    }
    else{
        dispatch_queue_t  imageQueue_ = dispatch_queue_create("com.aequor.app.imageQueue", NULL);
        dispatch_async(imageQueue_, ^{
            UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://pagead2.googlesyndication.com/simgad/8447710804836610390"]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.thumbNailImageView.image=image;
                [dictOfImages setObject:image forKey:imgURL];
            });
        });
    }
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
/*
 -(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 }
 */

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320;
}

#pragma mark-Scroll Delegates
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
            [self.animateTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:path ,nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        else
        {
            fullvisible = NO;
        }
    }
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

#pragma mark-Video Player Observer
-(void)itemDidBufferPlaying:(id)object
{
    NSLog(@"Buffering");
}

-(void)itemDidFinishPlaying:(id)object
{
    NSLog(@"Finishing");
}

@end
