//
//  ApadViewController.m
//  語宙探險
//
//  Created by IUILAB on 2014/12/22.
//  Copyright (c) 2014年 D.A.C.K. All rights reserved.
//

#import "ApadViewController.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"
#import "MissionTableViewCell.h"

@interface ApadViewController ()
{
    NSMutableArray* missions;
}
@end

@implementation ApadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.missionTableView.delegate = self;
    self.missionTableView.dataSource = self;
    self.missionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    missions = [[NSMutableArray alloc] init];
    NSString* qryUpd = @"";
    NSString* qry = [NSString stringWithFormat:@"select * from MISSION_TABLE where m_sid = %d order by m_id;", self.sid];
    FMResultSet *rs = [DatabaseManager executeQuery:qry];
    while ([rs next])
    {
        NSDictionary* m = [[NSDictionary alloc] init];
        
        if([rs intForColumn:@"m_type"] == 1) {
            // 字典任務
            int total = 0;
            NSString* qryD = [NSString stringWithFormat:@"select count(d_id) from DICTIONARY_TABLE where d_sid = %d;", self.sid];
            FMResultSet *rsD = [DatabaseManager executeQuery:qryD];
            while ([rsD next])
            {
                total = [rsD intForColumnIndex:0];
            }
            
            int completed = 0;
            qryD = [NSString stringWithFormat:@"select count(d_id) from DICTIONARY_TABLE where d_sid = %d and d_get = 1;", self.sid];
            rsD = [DatabaseManager executeQuery:qryD];
            while ([rsD next])
            {
                completed = [rsD intForColumnIndex:0];
            }
            
            // 檢查全部字典任務完成沒
            NSString* completeText = [rs stringForColumn:@"m_complete"];
            if(total == completed && [rs intForColumn:@"m_complete"] == 0) {
                completeText = @"1";
                qryUpd = [qryUpd stringByAppendingString:[NSString stringWithFormat:@"update MISSION_TABLE set m_complete = 1 where m_sid = %d and m_type = 1;", self.sid]];
            }
            
            NSString* subTitle = [NSString stringWithFormat:@"(%d/%d)", completed, total];

            m = [NSDictionary dictionaryWithObjects:@[@"字典", [rs stringForColumn:@"m_title"], subTitle, completeText] forKeys:@[@"type", @"title", @"subtitle", @"complete"]];
        } else if ([rs intForColumn:@"m_type"] == 2) {
            // 能量任務
            int total = 0;
            NSString* qryE = [NSString stringWithFormat:@"select count(e_id) from ENERGY_TABLE where e_sid = %d;", self.sid];
            FMResultSet *rsE = [DatabaseManager executeQuery:qryE];
            while ([rsE next])
            {
                total = [rsE intForColumnIndex:0];
            }
            
            int completed = 0;
            qryE = [NSString stringWithFormat:@"select count(e_id) from ENERGY_TABLE where e_sid = %d and e_get = 1;", self.sid];
            rsE = [DatabaseManager executeQuery:qryE];
            while ([rsE next])
            {
                completed = [rsE intForColumnIndex:0];
            }
            // 檢查全部能量任務完成沒
            NSString* completeText = [rs stringForColumn:@"m_complete"];
            if(total == completed && [rs intForColumn:@"m_complete"] == 0) {
                completeText = @"1";
                qryUpd = [qryUpd stringByAppendingString:[NSString stringWithFormat:@"update MISSION_TABLE set m_complete = 1 where m_sid = %d and m_type = 2;", self.sid]];
            }
            
            NSString* subTitle = [NSString stringWithFormat:@"(%d/%d)", completed, total];
            
            m = [NSDictionary dictionaryWithObjects:@[@"能量", [rs stringForColumn:@"m_title"], subTitle, completeText] forKeys:@[@"type", @"title", @"subtitle", @"complete"]];
        } else {
            // 遊戲任務
            // 如果還沒加標題項目
            BOOL yetAdded = YES;
            for(int i = 0; i<missions.count; i++) {
                NSDictionary* temp = [missions objectAtIndex:i];
                if([[temp valueForKey:@"title"] isEqualToString:[rs stringForColumn:@"m_title"]]) {
                    yetAdded = NO;
                }
            }
            
            if(yetAdded) {
                // 加入標題項目
                int total = 0;
                NSString* qryG = [NSString stringWithFormat:@"select count(m_id) from MISSION_TABLE where m_sid = %d and m_title = '%@';", self.sid, [rs stringForColumn:@"m_title"]];
                FMResultSet *rsG = [DatabaseManager executeQuery:qryG];
                while ([rsG next])
                {
                    total = [rsG intForColumnIndex:0];
                }
                
                int completed = 0;
                qryG = [NSString stringWithFormat:@"select count(m_id) from MISSION_TABLE where m_sid = %d and m_title = '%@' and m_complete = 1;", self.sid, [rs stringForColumn:@"m_title"]];
                rsG = [DatabaseManager executeQuery:qryG];
                while ([rsG next])
                {
                    completed = [rsG intForColumnIndex:0];
                }
                
                NSString* subTitle = [NSString stringWithFormat:@"(%d/%d)", completed, total];
                NSString* complete = completed/total == 1? @"1":@"0";
                
                 NSDictionary *mG = [NSDictionary dictionaryWithObjects:@[@"遊戲標題", [rs stringForColumn:@"m_title"], subTitle, complete] forKeys:@[@"type", @"title", @"subtitle", @"complete"]];
                [missions addObject:mG];
            }
            
            // 加入任務項目
            NSString* subTitle = [rs intForColumn:@"m_complete"]? @"(1/1)": @"GO";
            m = [NSDictionary dictionaryWithObjects:@[@"遊戲", [rs stringForColumn:@"m_description"], subTitle, [rs stringForColumn:@"m_complete"]] forKeys:@[@"type", @"title", @"subtitle", @"complete"]];
        }
        
        [missions addObject:m];
    }
    
    // 更新 m_complete
    if(![qryUpd isEqualToString:@""]) {
        [DatabaseManager executeModifySQL:qryUpd];
    }
    
    [self.missionTableView reloadData];
    [self checkCompleteState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return missions.count;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    long int rowNumber = [indexPath row];
    NSDictionary* m = (NSDictionary*)missions[rowNumber];
    
    if([[m valueForKey:@"type"] isEqualToString:@"遊戲標題"] || [[m valueForKey:@"type"] isEqualToString:@"能量"]) {
        return FALSE;
    }
    
    return TRUE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MissionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"missionCell"];
    
    if ( cell == nil ) {
        cell = [[MissionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"missionCell"];
    }
    
    long int rowNumber = [indexPath row];
    NSDictionary* m = (NSDictionary*)missions[rowNumber];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.lblTitle setText:[m valueForKey:@"title"]];
    [cell.lblSubTitle setText:[m valueForKey:@"subtitle"]];
    
    if([[m valueForKey:@"type"] isEqualToString:@"遊戲"]) {
        // 標題縮排
        [cell.lblTitle setFrame:CGRectMake(40, 11, 208, 27)];
        [cell.lblTitle setFont:[UIFont systemFontOfSize:17.0]];
        [cell.lblSubTitle setTextColor:[UIColor colorWithRed:0.0 green:175.0/255.0 blue:1.0 alpha:1.0]];
    }
    
    // 已完成，顯示綠色
    if([[m valueForKey:@"complete"] isEqualToString:@"1"]) {
        [cell.lblTitle setTextColor:[UIColor greenColor]];
        [cell.lblSubTitle setTextColor:[UIColor greenColor]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long int rowNumber = [indexPath row];
    NSDictionary* m = (NSDictionary*)missions[rowNumber];
    
    // 尚未完成
    if([[m valueForKey:@"complete"] isEqualToString:@"0"]) {
        if([[m valueForKey:@"type"] isEqualToString:@"字典"]) {
            [self.delegate directToDictionary];
        } else if ([[m valueForKey:@"type"] isEqualToString:@"遊戲"]) {
            [self.delegate directToGame:[m valueForKey:@"title"]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Rundown

- (void)checkCompleteState
{
    NSString* qry = [NSString stringWithFormat:@"select count(m_id) from MISSION_TABLE where m_sid = %d and m_complete = 0;", self.sid];
    FMResultSet *rs = [DatabaseManager executeQuery:qry];
    while ([rs next])
    {
        if([rs intForColumnIndex:0] == 0) {
            [self.btnComplete setHidden:NO];
        }
    }
}

- (IBAction)btnCompleteClicked:(id)sender {
    [self.delegate directToStory];
}

@end
