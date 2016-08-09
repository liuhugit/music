//
//  ViewController.m
//  映月播放器
//
//  Created by 刘虎 on 16/8/6.
//  Copyright © 2016年 刘虎. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVMetadataItem.h>
#import "Masonry.h"
// 主屏幕大小
#define SCREEN_W [[UIScreen  mainScreen] bounds].size.width
#define SCREEN_H [[UIScreen  mainScreen] bounds].size.height

// 比例大小
#define PROPORTION_H(num) ((num / 667.0) * SCREEN_H)
#define PROPORTION_W(num) ((num / 375.0) * SCREEN_W)


@interface ViewController (){
    NSMutableArray *_musicArray;
    int a;
    CGFloat musicTime;
    
    CGFloat mySliderFloat;//slider的值
    
    CGFloat sliderTime;//slider从哪儿开始的值
    
    NSMutableDictionary *_volDic;//保存音量
}

@property (nonatomic,strong)AVAudioPlayer *player;

@property (nonatomic,strong)UIImageView   *musicImage;//音乐图片

@property (nonatomic,strong)UILabel *musicNameLabel;//音乐名字

@property (nonatomic,strong)UILabel *artNameLabel;//音乐家

@property (nonatomic,strong)UISlider *slider;//进度条

@property (nonatomic,strong)NSTimer  *timer;//定时

@property (nonatomic,strong)NSString *allTimeString;//总时长

@property (nonatomic,strong)UISlider *volSlider;//音量

@property (nonatomic,strong)CABasicAnimation *animation;//动画

@end

@implementation ViewController



- (void)action_timer:(NSTimer *)timer{
    musicTime += 1;
    UILabel *label = [self.view viewWithTag:300];
    NSArray *timeArr = [self computTime:musicTime];
    NSString *timeString = timeArr[0];
    if ([timeString isEqualToString:_allTimeString]) {
        label.text = @"00:00";
        sliderTime = 0;
        musicTime = 0;
        if (a < _musicArray.count - 1) {
            a ++;
        }else{
            a = 0;
        }
        [self MyAVAudioPlayer];
        [_player play];
        [self computeMusicTime];
        [self getMusicMessage];
    }else{
        label.text = timeString;
    }
    
    _slider.value = [timeArr[1] floatValue];
 
}


- (NSArray *)computTime:(CGFloat )time{
    NSString *timeString = @"";
    CGFloat allSliderTime = 0;
    if (time < 10) {
        timeString = [NSString stringWithFormat:@"00:0%.0f",musicTime];
        mySliderFloat = musicTime * 0.01;
    }else if (time > 9 && time < 60){
        timeString = [NSString stringWithFormat:@"00:%.0f",musicTime];
        mySliderFloat = musicTime * 0.01;
    }else if (time > 59){
        NSInteger min = time/60;
        CGFloat floatTime = time - min * 60;
        if (min < 10) {
            if (floatTime < 10) {
                timeString = [NSString stringWithFormat:@"0%ld:0%.0f",min,floatTime];
            }else{
                timeString = [NSString stringWithFormat:@"0%ld:%.0f",min,floatTime];
            }
        }else{
            if (floatTime < 10) {
                timeString = [NSString stringWithFormat:@"%ld:0%.0f",min,floatTime];
            }else{
                timeString = [NSString stringWithFormat:@"%ld:%.0f",min,floatTime];
            }
        }
        allSliderTime = min + floatTime * 0.01;
    }
    NSArray *array = @[timeString,[NSString stringWithFormat:@"%f",allSliderTime]];
    return array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    musicTime = 0;
    sliderTime = 0;
    _volDic = @{}.mutableCopy;
    self.view.backgroundColor = [UIColor whiteColor];
    _musicArray = @[@"遥远的她.mp3",@"喜欢你.mp3",@"123.mp3"].mutableCopy;
    a = 0;
    [self initializeUserinterface];
}


- (void)MyAVAudioPlayer{
    NSURL *url = [[NSBundle mainBundle]URLForResource:_musicArray[a] withExtension:nil];
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    if (_volDic.count > 0) {
        _player.volume = [[_volDic objectForKey:@"vol"] floatValue];
    }else{
        _player.volume = 1;
    }
    _player.currentTime = sliderTime;
    [_player prepareToPlay];//缓冲
}





- (void)initializeUserinterface{
    NSArray *array = @[@"上一曲",@"开始",@"下一曲"];
    for (int i = 0; i < 3; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor orangeColor];
        [button addTarget:self action:@selector(action_Mybutton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.tag = 666 + i;
        [self.view addSubview:button];
        CGFloat left = SCREEN_W/2 - PROPORTION_H(90) + i * PROPORTION_H(70);
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(PROPORTION_H(-67));
            make.left.equalTo(self.view).offset(left);
            make.size.mas_equalTo(CGSizeMake(PROPORTION_H(60), PROPORTION_H(40)));
        }];
    }
    
    
    _musicImage = [[UIImageView alloc]initWithFrame:CGRectMake(PROPORTION_H(50), PROPORTION_H(150), PROPORTION_H(280), PROPORTION_H(280))];
    _musicImage.layer.masksToBounds = YES;
    _musicImage.layer.cornerRadius = PROPORTION_H(140);
    [self.view addSubview:_musicImage];
    
    
    _musicNameLabel = [[UILabel alloc]init];
    _musicNameLabel.textAlignment = NSTextAlignmentCenter;
    _musicNameLabel.textColor = [UIColor orangeColor];
    [self.view addSubview:_musicNameLabel];
    [_musicNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.left.equalTo(self.view).offset(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_W,PROPORTION_H(20)));
    }];
    
    
    _artNameLabel = [[UILabel alloc]init];
    _artNameLabel.textAlignment = NSTextAlignmentCenter;
    _artNameLabel.textColor = [UIColor orangeColor];
    [self.view addSubview:_artNameLabel];
    [_artNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.left.equalTo(self.view).offset(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_W,PROPORTION_H(20)));
    }];
    
    //音量
    _volSlider = [[UISlider alloc]init];
    _volSlider.minimumValue = 0;
    _volSlider.maximumValue = 1;
    _volSlider.value = 0.5;
    _volSlider.continuous = YES;
    [_volSlider addTarget:self action:@selector(action_volSlider:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_volSlider];
    
    [_volSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(PROPORTION_H(90));
        make.left.equalTo(self.view).offset(PROPORTION_H(50));
        make.size.mas_equalTo(CGSizeMake(SCREEN_W - PROPORTION_H(100), PROPORTION_H(30)));
    }];
    
    //进度条
    _slider = [[UISlider alloc]init];
    _slider.userInteractionEnabled = YES;
    _slider.minimumValue = 0;
    _slider.continuous = YES;//滑动就改变值
    [_slider addTarget:self action:@selector(action_slider:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(PROPORTION_H(490));
        make.left.equalTo(self.view).offset(PROPORTION_H(50));
        make.size.mas_equalTo(CGSizeMake(SCREEN_W - PROPORTION_H(100), PROPORTION_H(30)));
    }];
    
    
    for (int i = 0; i < 2; i ++) {
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.text = @"00:00";
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.tag = 300 + i;
        [self.view addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(PROPORTION_H(495));
            make.left.equalTo(self.view).offset(5 + i * (SCREEN_W - PROPORTION_H(55)));
            make.size.mas_equalTo(CGSizeMake(PROPORTION_H(50), PROPORTION_H(20)));
        }];
    }
    
    //定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(action_timer:) userInfo:nil repeats:YES];
    //音乐没开始播放先关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
    
    [self MyAVAudioPlayer];
    [self computeMusicTime];
    [self getMusicMessage];
}


//音量
- (void)action_volSlider:(UISlider *)slider{
    _player.volume = slider.value;
    [_volDic setObject:[NSString stringWithFormat:@"%f",slider.value] forKey:@"vol"];
}


//slider进度条方法
- (void)action_slider:(UISlider *)slider{
    UILabel *label = [self.view viewWithTag:300];
    NSArray *arr = [self computTime:slider.value * 60];
    sliderTime = slider.value * 60;
    musicTime = slider.value * 60;
    _player.currentTime = sliderTime;
    label.text = arr[0];
}


//获取音乐全部信息
- (void)getMusicMessage{
//    NSString *path = [[NSBundle mainBundle]pathForResource:_musicArray[a] ofType:@"mp3"];
    NSString *path = [[NSBundle mainBundle]pathForAuxiliaryExecutable:_musicArray[a]];
    NSURL *fileUrl = [NSURL fileURLWithPath:path];

    NSData *data = nil;
    //初始化媒体文件
    AVURLAsset *avUrlSet = [[AVURLAsset alloc]initWithURL:fileUrl options:nil];
    
    //读取文件中的数据
    for (NSString *format in [avUrlSet availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [avUrlSet metadataForFormat:format]) {
            //artwork这个key对应的value里面存的就是封面缩略图，其他key可以取出其它摘要信息，例如title-标题
            if ([metadataItem.commonKey isEqualToString:@"title"]) {
                NSString *titleString = [NSString stringWithFormat:@"%@",metadataItem.value];
                _musicNameLabel.text = titleString;
            }
            
            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                data = (NSData *)metadataItem.value;
                _musicImage.image = [UIImage imageWithData:data];
            }
            
            if ([metadataItem.commonKey isEqualToString:@"artist"]) {
                NSString *string = [NSString stringWithFormat:@"%@",metadataItem.value];
                _artNameLabel.text = string;
            }
        }
    }
    if (!data) {
        NSLog(@"没有图片");
        _musicImage.image = [UIImage imageNamed:@"123.jpg"];
    }
    _musicImage = [self rotate360DegreeWithImageView:_musicImage];
}

//计算音乐总时长
- (void)computeMusicTime{
    UILabel *label = [self.view viewWithTag:301];
    if (_player) {
        CGFloat time = _player.duration;
        NSInteger min = time/60;
        CGFloat residueTime = time - min * 60;
        _allTimeString = @"";
        if (min < 10) {
            _allTimeString = [NSString stringWithFormat:@"0%ld:%.0f",min,residueTime];
        }else{
            _allTimeString = [NSString stringWithFormat:@"%ld:%.0f",min,residueTime];
        }
        label.text = _allTimeString;
        CGFloat sliderFloat = min + residueTime * 0.01;
        _slider.maximumValue = sliderFloat;
    }
}

- (void)action_Mybutton:(UIButton *)sender{
    UILabel *label = [self.view viewWithTag:300];
    UIButton *but = [self.view viewWithTag:667];
    switch (sender.tag) {
        case 666:{//上一曲
            [_musicImage.layer addAnimation:_animation forKey:nil];
            sliderTime = 0;
            [_timer setFireDate:[NSDate distantPast]];
            but.selected = YES;
            [but setTitle:@"暂停" forState:UIControlStateNormal];
            if (a > 0) {
                a --;
                label.text = @"00:00";
                musicTime = 0;
                [self MyAVAudioPlayer];
                [_player play];
                [self computeMusicTime];
            }else if (a == 0) {
                label.text = @"00:00";
                musicTime = 0;
                a = (int)_musicArray.count - 1;
                [self MyAVAudioPlayer];
                [_player play];
                [self computeMusicTime];
            }
            [self getMusicMessage];
        }break;
        case 667:{//开始暂停
            if (sender.selected) {
                [self pauseLayer:_musicImage.layer];//暂停
                [_timer setFireDate:[NSDate distantFuture]];//关闭定时器
                [_player pause];
                [sender setTitle:@"开始" forState:UIControlStateNormal];
                sender.selected = NO;
            }else{
                if (_musicImage.layer.speed == 0) {
                    [self resumeLayer:_musicImage.layer];//开始
                }else{
                    [_musicImage.layer addAnimation:_animation forKey:nil];
                }
                [sender setTitle:@"暂停" forState:UIControlStateNormal];
                sender.selected = YES;
                [self MyAVAudioPlayer];
                //开启定时器
                [_timer setFireDate:[NSDate distantPast]];
                [_player play];
                _player.currentTime = musicTime;
                [self computeMusicTime];
            }
            
        }break;
        case 668:{//下一曲
            [_musicImage.layer addAnimation:_animation forKey:nil];
            sliderTime = 0;
            [_timer setFireDate:[NSDate distantPast]];
            but.selected = YES;
            [but setTitle:@"暂停" forState:UIControlStateNormal];
            if (a < _musicArray.count - 1) {
                a ++;
                label.text = @"00:00";
                musicTime = 0;
                [self MyAVAudioPlayer];
                [_player play];
                [self computeMusicTime];
            }else  if (a + 1 == _musicArray.count) {
                a = 0;
                label.text = @"00:00";
                musicTime = 0;
                [self MyAVAudioPlayer];
                [_player play];
                [self computeMusicTime];
            }
            [self getMusicMessage];
        }break;
        default:
            break;
    }
}


//图片的旋转动画
- (UIImageView *)rotate360DegreeWithImageView:(UIImageView *)imageView{
    _animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    _animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    //围绕Z轴旋转，垂直与屏幕
    _animation.toValue = [ NSValue valueWithCATransform3D:
                         
                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    _animation.duration = 10;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    _animation.cumulative = YES;
    _animation.repeatCount = 100000000000;
    _animation.autoreverses = NO;
    
    //在图片边缘添加一个像素的透明区域，去图片锯齿
    CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContext(imageRrect.size);
    [imageView.image drawInRect:CGRectMake(1,1,imageView.frame.size.width-2,imageView.frame.size.height-2)];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    [imageView.layer addAnimation:_animation forKey:nil];
    return imageView;
}


//暂停layer上面的动画
- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续layer上面的动画
- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

@end








































