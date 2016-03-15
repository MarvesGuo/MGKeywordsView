//
//  ViewController.m
//  MGKeywordsView
//
//  Created by Marves Guo on 16/3/11.
//  Copyright © 2016年 Marves Guo. All rights reserved.
//

#import "ViewController.h"
#import "SubViewController.h"
#import "MGKeyowrdsView.h"

@interface ViewController ()

@end





@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SubViewController *subVC = [[SubViewController alloc]initWithShowType:indexPath.row];
    [self.navigationController pushViewController:subVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}






@end
