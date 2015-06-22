//
//  AccountViewController.m
//  Vialer
//
//  Created by Harold on 18/06/15.
//  Copyright (c) 2015 VoIPGRID. All rights reserved.
//

#import "AccountViewController.h"
#import "VoIPGRIDRequestOperationManager.h"
#import "AccountViewFooterView.h"
#import "EditNumberTableViewController.h"

@interface AccountViewController ()
@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //3 if you want to display logout
}
//To enable the logout button,
//- change number of sections to 3
//- change LOGOUT_BUTTON_SECTION to 1
//- change NUMBERS_SECTION to 2

#define VOIP_ACCOUNT_SECTION 0
#define SIP_ACCOUNT_ROW 0
#define SIP_PASSWORD_ROW 1

#define LOGOUT_BUTTON_SECTION 99 //unused should be 1
#define LOGOUT_BUTTON_ROW 0

#define NUMBERS_SECTION 1 //was 2
#define MY_NUMBER_ROW 0
#define OUTGOING_NUMBER_ROW 1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == LOGOUT_BUTTON_SECTION)
        return 1;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConfigViewCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSLog(@"User: %@",[VoIPGRIDRequestOperationManager sharedRequestOperationManager].user);
    
    if (indexPath.section == VOIP_ACCOUNT_SECTION) {
        if (indexPath.row == SIP_ACCOUNT_ROW) {
            cell.textLabel.text = NSLocalizedString(@"SIP Account", nil);
            cell.detailTextLabel.text = [VoIPGRIDRequestOperationManager sharedRequestOperationManager].sipAccount;
        } else if (indexPath.row == SIP_PASSWORD_ROW) {
            cell.textLabel.text = NSLocalizedString(@"Password", nil);
            cell.detailTextLabel.text = [VoIPGRIDRequestOperationManager sharedRequestOperationManager].sipPassword;
        }
    } else if (indexPath.section == LOGOUT_BUTTON_SECTION) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = NSLocalizedString(@"Logout", nil);
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    } else if (indexPath.section == NUMBERS_SECTION) {
        if (indexPath.row == MY_NUMBER_ROW) {
            cell.textLabel.text = NSLocalizedString(@"My Number", nil);
            cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"MobileNumber"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        } else if (indexPath.row == OUTGOING_NUMBER_ROW) {
            cell.textLabel.text = NSLocalizedString(@"Outgoing Number", nil);
            cell.detailTextLabel.text = [[VoIPGRIDRequestOperationManager sharedRequestOperationManager] outgoingNumber];
        }
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == VOIP_ACCOUNT_SECTION)
        return 35;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == VOIP_ACCOUNT_SECTION)
        return NSLocalizedString(@"VoIP Account", nil);
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //The footer will be added to the last displayed section
    if (section == NUMBERS_SECTION) {
        NSLog(@"Tableview size %@", NSStringFromCGRect(self.tableView.frame));
        CGRect frameOfLastRow = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:OUTGOING_NUMBER_ROW inSection:NUMBERS_SECTION]];
        NSLog(@"fame of last row: %@", NSStringFromCGRect(frameOfLastRow));
        
        //the empty space below the last cell is the complete height of the tableview minus
        //the y position of the last row + the last rows height.
        CGRect emptyFrameBelowLastRow = CGRectMake(0, 0, self.tableView.frame.size.width,
                   self.tableView.frame.size.height - (frameOfLastRow.origin.y + frameOfLastRow.size.height));
        
        NSLog(@"empty space: %@", NSStringFromCGRect(emptyFrameBelowLastRow));
        
        return [[AccountViewFooterView alloc] initWithFrame:emptyFrameBelowLastRow];
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LOGOUT_BUTTON_SECTION && indexPath.row == LOGOUT_BUTTON_ROW) {
        [[VoIPGRIDRequestOperationManager sharedRequestOperationManager] logout];
        [self.tableView reloadData];
    } else if (indexPath.section == NUMBERS_SECTION && indexPath.row == MY_NUMBER_ROW){
        
        EditNumberTableViewController *editNumberController = [[EditNumberTableViewController alloc] initWithNibName:@"EditNumberTableViewController" bundle:[NSBundle mainBundle]];
        editNumberController.numberToEdit = [[NSUserDefaults standardUserDefaults] objectForKey:@"MobileNumber"];
        editNumberController.delegate = self;
        [self.navigationController pushViewController:editNumberController animated:YES];
    }
}

#pragma mark - Editnumber delegate

- (void)numberHasChanged:(NSString *)newNumber {
    //Update the userdefaults
    [[NSUserDefaults standardUserDefaults] setObject:newNumber forKey:@"MobileNumber"];
    //Update the tableView Cell
    UITableViewCell *myNumberCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MY_NUMBER_ROW inSection:NUMBERS_SECTION]];
    myNumberCell.detailTextLabel.text = newNumber;
}

@end
