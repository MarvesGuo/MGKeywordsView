//
//  MGKeyowrdsView.h
//  MGKeywordsView
//
//  Created by Marves Guo on 16/3/11.
//  Copyright © 2016年 Marves Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGKeyowrdsViewItem;


typedef NS_ENUM(NSInteger, MGKeyowrdsViewType) {
    MGKeyowrdsViewTypeDefault = 0,              //no user interface.
    MGKeyowrdsViewTypeExampleClick1,            //click
    MGKeyowrdsViewTypeExampleClick2,            //click
    MGKeyowrdsViewTypeExampleRadio,             //radio
    MGKeyowrdsViewTypeDiseaseMultiSelect,       //multi-select
    //
};


@protocol MGKeyowrdsViewDelegate;


@interface MGKeyowrdsView : UIView

@property (nonatomic, weak) id<MGKeyowrdsViewDelegate> delegate;


+ (instancetype)keyWordsViewWithType:(MGKeyowrdsViewType)type maxWidth:(CGFloat)maxWidth items:(NSArray<MGKeyowrdsViewItem *> *)items  numberOfLines:(NSInteger)numberOfLines;    //if numberOfLines equal 0,means max number of lines.


- (NSInteger)currentNumberOfLines;
- (NSInteger)maxNumberOfLines; //不限制最大行数
- (CGFloat)heightWithNumberOfLines:(NSInteger) numberOfLines;


//刷新
- (CGFloat)refreshForNumberOfLines:(NSInteger)lines;
//单选多选
- (void)setItemSelectedAtIndex:(NSInteger)index isSelected:(BOOL)isSelected needCallBack:(BOOL)needCallBack;


@end

@protocol MGKeyowrdsViewDelegate <NSObject>
//Click
-(void)keyWordsView:(MGKeyowrdsView *)keyWordsView didClickedWithIndex:(NSInteger)index item:(MGKeyowrdsViewItem *)item;
//单选
-(void)keyWordsView:(MGKeyowrdsView *)keyWordsView didRadioedWithIndex:(NSInteger)index item:(MGKeyowrdsViewItem *)item;
//多选选中的  可能为空数组
-(void)keyWordsView:(MGKeyowrdsView *)keyWordsView didMultiselectChangedWithItems:(NSArray<MGKeyowrdsViewItem *> *)selectedItems;

@end



@interface MGKeyowrdsViewItem : NSObject

@property (copy, nonatomic)     NSString *  title;
@property (assign, nonatomic)   BOOL        selected;   //是否选中(radio or multi-select)

@property (strong, nonatomic)   id          sender;     //业务层需要的参数 可不写

@end



