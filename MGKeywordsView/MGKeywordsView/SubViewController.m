//
//  SubViewController.m
//  MGKeywordsView
//
//  Created by 虔灵 on 16/3/15.
//  Copyright © 2016年 Marves Guo. All rights reserved.
//

#import "SubViewController.h"

@interface SubViewController ()
<
    MGKeyowrdsViewDelegate
>
{
    MGKeyowrdsViewType _type;
    
    NSArray *_items;
}

- (void)p_initData;
- (void)p_initUI;

- (NSArray<MGKeyowrdsViewItem *> *)p_keywordsViewDataSourceWithType:(MGKeyowrdsViewType)type ;

@end

@implementation SubViewController


- (instancetype)initWithShowType:(MGKeyowrdsViewType)showType {
    if (self = [super init])
    {
        _type = showType;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_initData];
    [self p_initUI];
}



-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didClickedWithIndex:(NSInteger)index item:(MGKeyowrdsViewItem *)item {
    
}

-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didRadioedWithIndex:(NSInteger)index item:(MGKeyowrdsViewItem *)item {
    
}

-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didMultiselectChangedWithItems:(NSArray<MGKeyowrdsViewItem *> *)selectedItems {
    
}



- (void)p_initData {
    _items = [self p_keywordsViewDataSourceWithType:_type];
}


- (void)p_initUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    MGKeyowrdsView *keywordsView = [MGKeyowrdsView keywordsViewWithType:_type maxWidth:[UIScreen mainScreen].bounds.size.width items:_items numberOfLines:0];
    
    keywordsView.frame = CGRectMake(0, 64,[UIScreen mainScreen].bounds.size.width , [keywordsView heightWithNumberOfLines:0]);
    [self.view addSubview:keywordsView];
}


- (NSArray<MGKeyowrdsViewItem *> *)p_keywordsViewDataSourceWithType:(MGKeyowrdsViewType)type {
    
    NSMutableArray *rstItems = [[NSMutableArray alloc]initWithCapacity:50];
    
    NSInteger i = 0;
    do {
        MGKeyowrdsViewItem *item = [[MGKeyowrdsViewItem alloc]init];
        item.title = [NSString stringWithFormat:@"标签%zi",arc4random()%100000];
        [rstItems addObject:item];
        i++;
    } while (i < arc4random()%100);
    
    
    return [NSArray arrayWithArray:rstItems];
}



@end
