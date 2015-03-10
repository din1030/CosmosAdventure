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
    [self.imgRepair setHidden:YES];
    
    // 填入內容
    if(self.pageIndex == 0) {
        [self.page_bg setImage:[UIImage imageNamed:@"dic_cover.png"]];
    } else {
        [self loadContent];
        [self.lblPage setText:[NSString stringWithFormat:@"第 %d 頁", self.thePage.did]];
    }
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
        
        // 尚未拿到
        if(self.thePage.dget == 0) {
            cutWord = [self.thePage.dtitle substringWithRange:NSMakeRange(cutIndex, 1)];
            NSString* cutTitle = [self.thePage.dtitle stringByReplacingCharactersInRange:NSMakeRange(cutIndex,1) withString:@"＋"];
            [self.lblTitle setText:cutTitle];
            
            // 髒髒按鈕
            UIButton* btnDirt = [[UIButton alloc] initWithFrame:CGRectMake(self.thePage.dcutout*80, 122, 90, 90)];
            [btnDirt setBackgroundImage:[UIImage imageNamed:@"dirt.png"] forState:UIControlStateNormal];
            [btnDirt addTarget:self action:@selector(btnDirtClicked) forControlEvents:UIControlEventTouchUpInside];
            [btnDirt setTag:self.thePage.did];
            [self.view addSubview:btnDirt];
        } else {
            // 補丁
            [self.imgRepair setFrame:CGRectMake(self.thePage.dcutout*80, 122, 90, 90)];
            [self.imgRepair setHidden:NO];
            [self.lblTitle setText:self.thePage.dtitle];
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
    [self.delegate shouldStartOCR:self.thePage.did cutword:cutWord fullword:self.thePage.dtitle  description:self.thePage.ddescription];
}

@end
