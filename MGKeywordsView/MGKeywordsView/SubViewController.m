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
    MGKeyowrdsView *_keywordsView;
    UITextView *_textView;

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
    _textView.text = [NSString stringWithFormat:@"Clicked : %@",item.title];
}

-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didRadioedWithIndex:(NSInteger)index item:(MGKeyowrdsViewItem *)item {
    _textView.text = [NSString stringWithFormat:@"Radioed : %@",item.title];
}

-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didMultiselectChangedWithItems:(NSArray<MGKeyowrdsViewItem *> *)selectedItems {
    
    NSMutableString *showStr = @"".mutableCopy;
    [selectedItems enumerateObjectsUsingBlock:^(MGKeyowrdsViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [showStr appendString:obj.title];
        [showStr appendString:@"   "];
    }];

    showStr.length == 0 ? [showStr appendString:@"Deselect"] : [showStr insertString:@"selected:\n" atIndex:0];
    _textView.text = showStr;
}



- (void)p_initData {
    _items = [self p_keywordsViewDataSourceWithType:_type];
}


- (void)p_initUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _keywordsView = [MGKeyowrdsView keywordsViewWithType:_type maxWidth:[UIScreen mainScreen].bounds.size.width items:_items numberOfLines:0];
    _keywordsView.frame = CGRectMake(0, 64,_keywordsView.frame.size.width , _keywordsView.frame.size.height);
    _keywordsView.delegate = self;
    [self.view addSubview:_keywordsView];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height - 350)];
    _textView.editable = NO;
    _textView.font = [UIFont boldSystemFontOfSize:21];
    [self.view addSubview:_textView];
}


- (NSArray<MGKeyowrdsViewItem *> *)p_keywordsViewDataSourceWithType:(MGKeyowrdsViewType)type {
    
    NSMutableArray *rstItems = @[].mutableCopy;
    
    NSInteger i = 0, maxCount = 10 + arc4random()%20;
    
    do {
        MGKeyowrdsViewItem *item = [[MGKeyowrdsViewItem alloc]init];
        item.title = [NSString stringWithFormat:@"标签%zi",arc4random()%1000];
        [rstItems addObject:item];
        i++;
    } while (i < maxCount);
    
    
    return [NSArray arrayWithArray:rstItems];
}



@end
