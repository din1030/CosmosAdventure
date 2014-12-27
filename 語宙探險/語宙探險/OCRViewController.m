//
//  OCRViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "OCRViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"

@interface OCRViewController ()
{
    AVCaptureSession *myCaptureSession;
    AVCaptureStillImageOutput *myStillImageOutput;
    AVCaptureVideoPreviewLayer *myPreviewLayer;
}
@end

@implementation OCRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 場景圖片
    [self.ocr_bg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"stage%d.png", self.sid/10]]];
    
    // 設定OCR
    self.tesseract = [[G8Tesseract alloc] initWithLanguage:@"word"];
    self.tesseract.delegate = self;
    
    // Optional: Limit the character set Tesseract should try to recognize from
    self.tesseract.charWhitelist = self.correctWord;
    // Optional: Limit the character set Tesseract should not try to recognize from
    //tesseract.charBlacklist = @"OoZzBbSs";
    
    // Optional: Limit the area of the image Tesseract should recognize on to a rectangle
    //self.tesseract.rect = CGRectMake(0, 0, 400, 500);
    
    // Optional: Limit recognition time with a few seconds
    self.tesseract.maximumRecognitionTime = 2.0;
    
    // 設定照相
    // 建立 AVCaptureSession
    myCaptureSession = [[AVCaptureSession alloc] init];
    [myCaptureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    //建立 AVCaptureDeviceInput
    NSArray *myDevices = [AVCaptureDevice devices];
    //使用後置鏡頭當做輸入
    NSError *error = nil;
    for (AVCaptureDevice *device in myDevices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            
            AVCaptureDeviceInput *myDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            
            if (error) {
                //裝置取得失敗時的處理常式
            } else {
                [myCaptureSession addInput:myDeviceInput];
            }
        }
    }
    
    //建立 AVCaptureVideoPreviewLayer
    myPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:myCaptureSession];
    [myPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.photoView.layer addSublayer:myPreviewLayer];
    
    //啟用攝影機
    [myCaptureSession startRunning];
    
    //建立 AVCaptureStillImageOutput
    myStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *myOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey,nil];
    [myStillImageOutput setOutputSettings:myOutputSettings];
    
    [myCaptureSession addOutput:myStillImageOutput];
}

- (void)viewWillLayoutSubviews {
    myPreviewLayer.frame = CGRectMake(0, 0, 400, 500);
    if (myPreviewLayer.connection.supportsVideoOrientation) {
        myPreviewLayer.connection.videoOrientation = [self interfaceOrientationToVideoOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
}

- (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            break;
    }
    return AVCaptureVideoOrientationPortrait;
}

// 播放音效
- (void)playSound:(NSString*)fileName
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"]];
    NSError* err;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if(err) {
        NSLog(@"PlaySound Error: %@", [err localizedDescription]);
    } else {
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer play];
    }
}

#pragma mark - Photo

- (IBAction)btnRedoClicked:(id)sender {
    [self playSound:@"click"];
    // 重新拍照
    [self.photoView setHidden:NO];
    [self.photoImage setHidden:YES];
    [self.lblHint setText:@"拍下要找的字"];
    
    [self.btnShot setHidden:NO];
    [self.btnRedo setHidden:YES];
    [self.btnOCR setHidden:YES];
    [self.btnFinish setHidden:YES];
}

- (IBAction)btnCloseClicked:(id)sender {
    // 回到場景
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)btnShotClicked:(id)sender {
    [self playSound:@"click"];
    
    AVCaptureConnection *myVideoConnection = nil;
    
    //從 AVCaptureStillImageOutput 中取得正確類型的 AVCaptureConnection
    for (AVCaptureConnection *connection in myStillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                
                myVideoConnection = connection;
                if (myVideoConnection.supportsVideoOrientation) {
                    myVideoConnection.videoOrientation = [self interfaceOrientationToVideoOrientation:[UIApplication sharedApplication].statusBarOrientation];
                }
                break;
            }
        }
    }
    //擷取影像（包含拍照音效）
    [myStillImageOutput captureStillImageAsynchronouslyFromConnection:myVideoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        //完成擷取時的處理常式(Block)
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            //取得的靜態影像
            UIImage *myImage = [[UIImage alloc] initWithData:imageData];
            
            [self.photoImage setImage:myImage];
            [self.photoImage setFrame:CGRectMake(312, 124, 400, 500)];
            [self.photoImage setHidden:NO];
            
            // 開啟重拍
            [self.btnShot setHidden:YES];
            [self.btnRedo setHidden:NO];
            // 開啟辨識
            [self.btnOCR setHidden:NO];
        }
    }];
}

// 進行辨識
- (IBAction)btnOCRClicked:(id)sender {
    [self playSound:@"click"];
    [self.lblHint setText:@"....辨識中...."];
    [self startOCR];
}

// 確定結果
- (IBAction)btnFinishClicked:(id)sender {
    [self playSound:@"click"];
    // 儲存圖片
    NSString *fileString = [NSString stringWithFormat:@"Documents/%@.jpg", self.fullWord];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileString];
    
    // Write image to JPG
    [UIImageJPEGRepresentation(self.photoImage.image, 1.0) writeToFile:jpgPath atomically:YES];
    
    // 更新資料庫
    NSString* qry = [NSString stringWithFormat:@"update DICTIONARY_TABLE set d_get = 1 where d_title = '%@'", self.fullWord];
    [DatabaseManager executeModifySQL:qry];

    // 回到場景
    [self.delegate repairedPage:self.fullWord description:self.ddescription cutword:self.correctWord];
}

#pragma mark - OCR

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    [self.lblHint setText:[NSString stringWithFormat:@"....%lu....", (unsigned long)self.tesseract.progress]];
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)startOCR
{
    self.tesseract.image = [self.photoImage.image g8_blackAndWhite];
    // Start the recognition
    [self.tesseract recognize];
    
    // Retrieve the recognized text
    NSLog(@"recognizedText: %@", [self.tesseract recognizedText]);
    
    // You could retrieve more information about recognized text with that methods:
    NSArray *characterBoxes = self.tesseract.characterBoxes;
    //NSArray *characterChoices = self.tesseract.characterChoices;
    //NSArray *confidences = [self.tesseract confidencesByIteratorLevel:G8PageIteratorLevelWord];
    UIImage *imageWithBlocks = [self.tesseract imageWithBlocks:characterBoxes drawText:YES thresholded:NO];
    
    // 如果有偵測到正確的字
    if([[self.tesseract recognizedText] rangeOfString:self.correctWord].location == NSNotFound) {
        [self.lblHint setText:@"啥都沒找到，但還是先過關"];
        // 一切為了測試///////////////////////////////////////////////////////////////////////////////////
        [self.btnFinish setHidden:NO];
    } else {
        // 重新顯示照片
        [self.photoImage setImage:imageWithBlocks];
        [self.photoView setHidden:YES];
        [self.btnFinish setHidden:NO];
        [self.lblHint setText:[NSString stringWithFormat:@"找到「%@」囉！", self.correctWord]];
    }
    // 開啟互動
    [self.btnOCR setHidden:YES];
    [self.btnRedo setHidden:NO];
}

@end
