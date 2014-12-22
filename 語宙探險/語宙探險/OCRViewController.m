//
//  OCRViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "OCRViewController.h"

@interface OCRViewController ()
{
    AVCaptureSession *myCaptureSession;
    AVCaptureStillImageOutput *myStillImageOutput;
}
@end

@implementation OCRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 設定OCR
    self.tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng+chi_tra"];
    self.tesseract.delegate = self;
    
    // Optional: Limit the character set Tesseract should try to recognize from
    self.tesseract.charWhitelist = self.correctWord;
    // Optional: Limit the character set Tesseract should not try to recognize from
    //tesseract.charBlacklist = @"OoZzBbSs";
    
    // Optional: Limit the area of the image Tesseract should recognize on to a rectangle
    self.tesseract.rect = CGRectMake(0, 0, 400, 500);
    
    // Optional: Limit recognition time with a few seconds
    self.tesseract.maximumRecognitionTime = 2.0;
    
    // 設定照相
    // 建立 AVCaptureSession
    myCaptureSession = [[AVCaptureSession alloc] init];
    [myCaptureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    //建立 AVCaptureDeviceInput
    NSArray *myDevices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in myDevices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            NSLog(@"後攝影機硬體名稱: %@", [device localizedName]);
        }
        
        if ([device position] == AVCaptureDevicePositionFront) {
            NSLog(@"前攝影機硬體名稱: %@", [device localizedName]);
        }
        
        if ([device hasMediaType:AVMediaTypeAudio]) {
            NSLog(@"麥克風硬體名稱: %@", [device localizedName]);
        }
    }
    
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
    AVCaptureVideoPreviewLayer *myPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:myCaptureSession];
    [myPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //CGRect rect = CGRectMake(160, 180, 320, 240);
    [myPreviewLayer setBounds:self.photoView.frame];
    
    [self.photoView.layer addSublayer:myPreviewLayer];
    
    //啟用攝影機
    [myCaptureSession startRunning];
    
    //建立 AVCaptureStillImageOutput
    myStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *myOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey,nil];
    [myStillImageOutput setOutputSettings:myOutputSettings];
    
    [myCaptureSession addOutput:myStillImageOutput];
    
//    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
//    camera.delegate = self;
//    camera.allowsEditing = YES;
//    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"通知"
//                                                              message:@"無法使用相機"
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"確認"
//                                                    otherButtonTitles: nil];
//        [myAlertView show];
//    } else {
//        [self presentViewController:camera animated:YES completion:nil];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Photo

- (IBAction)tapGesture:(id)sender {
    NSLog(@"tapGesture");
    /*
    AVCaptureConnection *myVideoConnection = nil;
    
    //從 AVCaptureStillImageOutput 中取得正確類型的 AVCaptureConnection
    for (AVCaptureConnection *connection in myStillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                
                myVideoConnection = connection;
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
            [self.photoImage setHidden:NO];
            
            // 直接進行OCR
            self.tesseract.image = [myImage g8_blackAndWhite];
            [self startOCR];
            
            // 關閉互動
            [self.lblHint setText:@""];
            [self.btnClose setHidden:YES];
            [self.btnRedo setHidden:YES];
        }
    }];*/
}

- (IBAction)btnRedoClicked:(id)sender {
    // 重新拍照
    [self.photoImage setHidden:YES];
    [self.lblHint setText:@"點擊畫面拍照"];
    
    [self.btnRedo setHidden:YES];
}

- (IBAction)btnCloseClicked:(id)sender {
    // 回到場景
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)tapFinish:(id)sender {
    // 確定結果，儲存圖片，更新資料庫
    NSLog(@"tapFinish");
    
    // 回到場景
    [self dismissViewControllerAnimated:NO completion:nil];
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    
//    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
//    self.photoImageView.image = chosenImage;
//    
//    [picker dismissViewControllerAnimated:YES completion:NULL];
//}

#pragma mark - OCR

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)self.tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)startOCR
{
    // Start the recognition
    [self.tesseract recognize];
    
    // Retrieve the recognized text
    NSLog(@"recognizedText: %@", [self.tesseract recognizedText]);
    
    // You could retrieve more information about recognized text with that methods:
    NSArray *characterBoxes = self.tesseract.characterBoxes;
    NSArray *characterChoices = self.tesseract.characterChoices;
    NSArray *confidences = [self.tesseract confidencesByIteratorLevel:G8PageIteratorLevelWord];
    UIImage *imageWithBlocks = [self.tesseract imageWithBlocks:characterBoxes drawText:YES thresholded:NO];
    
    // 如果有偵測到正確的字
    if([[self.tesseract recognizedText] isEqualToString:self.correctWord]) {
        // 重新顯示照片
        [self.photoImage setImage:imageWithBlocks];
        // 開啟互動
        [self.lblHint setText:@"點擊畫面完成"];
        [self.btnClose setHidden:NO];
        [self.btnRedo setHidden:NO];
    } else {
        // 重新拍照
        [self.photoImage setHidden:YES];
        [self.lblHint setText:@"點擊畫面拍照"];
    }
}

@end
