//
//  PagesViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "PagesViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"
#import "BookViewController.h"

@interface PagesViewController ()
{
    NSString* cutWord;
}
@end

@implementation PagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 先隱藏按鈕
    [self.btnClose setHidden:YES];
    [self.btnNext setHidden:YES];
    [self.btnPrevious setHidden:YES];
    
    // 填入內容
    [self loadContent];
    [self.lblPage setText:[NSString stringWithFormat:@"第 %d 頁", self.thePage.did]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContent
{
    if(self.thePage.dcutout == 0) {
        [self.lblTitle setText:self.thePage.dtitle];
    } else {
        // 缺字
        int cutIndex = self.thePage.dcutout - 1;
        cutWord = [self.thePage.dtitle substringWithRange:NSMakeRange(cutIndex, 1)];
        NSString* cutTitle = [self.thePage.dtitle stringByReplacingCharactersInRange:NSMakeRange(cutIndex,1) withString:@"＋"];
        [self.lblTitle setText:cutTitle];
        
        // 尚未拿到
        if(self.thePage.dget == 0) {
            UIButton* btnDirt = [[UIButton alloc] initWithFrame:CGRectMake(cutIndex*80 + 77, 122, 90, 90)];
            [btnDirt setBackgroundImage:[UIImage imageNamed:@"dirt.png"] forState:UIControlStateNormal];
            [btnDirt addTarget:self action:@selector(btnDirtClicked) forControlEvents:UIControlEventTouchUpInside];
            [btnDirt setTag:self.thePage.did];
            [self.view addSubview:btnDirt];
        } else {
            // 取得之前拍的照片
            UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(cutIndex*80 + 77, 122, 90, 90)];
            
            NSString *fileString = [NSString stringWithFormat:@"Documents/%@.jpg", self.thePage.dtitle];
            NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:fileString];
            [photo setImage:[[UIImage alloc] initWithContentsOfFile:pngPath]];
            [photo setContentMode:UIViewContentModeScaleAspectFill];
            [photo setClipsToBounds:YES];
            [self.view addSubview:photo];
        }
    }
    [self.lblDescription setText:self.thePage.ddescription];
}

- (IBAction)btnCloseClicked:(id)sender {
    
}

- (IBAction)btnNextClicked:(id)sender {
    
}

- (IBAction)btnPreviousClicked:(id)sender {
}

- (void)btnDirtClicked
{
    [self.delegate shouldStartOCR:self.thePage.did cutword:cutWord fullword:self.thePage.dtitle];
}

@end
