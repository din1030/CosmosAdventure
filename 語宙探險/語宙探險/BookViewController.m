//
//  BookViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "BookViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"
#import "DictionaryObject.h"

@interface BookViewController ()
{
    NSMutableArray* pages;
}
@end

@implementation BookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    
    pages = [[NSMutableArray alloc] init];
    [pages addObject:@"cover"];
    FMResultSet *rs = [DatabaseManager executeQuery:@"select * from DICTIONARY_TABLE order by d_id;"];
    while ([rs next])
    {
        DictionaryObject* page = [DictionaryObject page:[rs intForColumn:@"d_id"]
                                                  title:[rs stringForColumn:@"d_title"]
                                            description:[rs stringForColumn:@"d_description"]
                                                 cutout:[rs intForColumn:@"d_cutout"]
                                                    sid:[rs intForColumn:@"d_sid"]
                                                    get:[rs intForColumn:@"d_get"]
                                                   date:[rs stringForColumn:@"d_date"]];
        
        [pages addObject:page];
    }
    
    // 從第一頁開始
    PagesViewController *startingViewController = [self viewControllerAtIndex:0];
    startingViewController.delegate = self;
    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PagesViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    [self playSound:@"page"];
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PagesViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [pages count]) {
        return nil;
    }
    [self playSound:@"page"];
    return [self viewControllerAtIndex:index];
}

- (PagesViewController*)viewControllerAtIndex:(NSUInteger)index
{
    if (([pages count] == 0) || (index >= [pages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PagesViewController *pageView = [self.storyboard instantiateViewControllerWithIdentifier:@"dictionary"];
    pageView.pageIndex = index;
    pageView.delegate = self;
    if(index) {
        pageView.thePage = pages[index];
    }
    return pageView;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [pages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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

#pragma mark - OCR delegate

- (void)shouldStartOCR:(int)did cutword:(NSString *)word fullword:(NSString *)title description:(NSString *)description
{
    // 傳回舞台，開啟OCR
    [self.delegateOCR startOCR:did cutword:word fullword:title description:description];
}

@end
