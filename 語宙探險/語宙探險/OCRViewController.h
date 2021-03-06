//
//  OCRViewController.h
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <TesseractOCR/TesseractOCR.h>

@protocol OCRViewControllerDelegate;

@interface OCRViewController : UIViewController<G8TesseractDelegate, AVAudioPlayerDelegate>

@property (nonatomic, assign) id<OCRViewControllerDelegate> delegate;

@property int sid;
@property int did;
@property (strong, nonatomic) G8Tesseract *tesseract;
@property (strong, nonatomic) NSString *correctWord;
@property (strong, nonatomic) NSString *fullWord;
@property (strong, nonatomic) NSString *ddescription;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIImageView *ocr_bg;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UIButton *btnRedo;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnShot;
@property (weak, nonatomic) IBOutlet UIButton *btnOCR;
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;

@property (weak, nonatomic) IBOutlet UILabel *lblHint;

- (IBAction)btnRedoClicked:(id)sender;
- (IBAction)btnCloseClicked:(id)sender;
- (IBAction)btnShotClicked:(id)sender;
- (IBAction)btnOCRClicked:(id)sender;
- (IBAction)btnFinishClicked:(id)sender;

@end

@protocol OCRViewControllerDelegate <NSObject>

- (void)repairedPage:(NSString*)title description:(NSString*)description cutword:(NSString*)cutword;

@end