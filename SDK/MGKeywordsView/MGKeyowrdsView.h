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
    MGKeyowrdsViewTypeExampleClick,            //click
    MGKeyowrdsViewTypeExampleClickAspectFill,   //click
    MGKeyowrdsViewTypeExampleRadio,             //radio
    MGKeyowrdsViewTypeExampleMultiSelect,       //multi-select
};


@protocol MGKeyowrdsViewDelegate;


@interface MGKeyowrdsView : UIView

@property (nonatomic, weak) id<MGKeyowrdsViewDelegate> delegate;


+ (instancetype)keywordsViewWithType:(MGKeyowrdsViewType)type maxWidth:(CGFloat)maxWidth items:(NSArray<MGKeyowrdsViewItem *> *)items  numberOfLines:(NSInteger)numberOfLines;    //if numberOfLines equal 0,means max number of lines.

- (NSInteger)currentNumberOfLines;
- (NSInteger)maxNumberOfLines;
- (CGFloat)heightWithNumberOfLines:(NSInteger) numberOfLines;

- (CGFloat)refreshForNumberOfLines:(NSInteger)lines;
- (void)setItemSelectedAtIndex:(NSInteger)index isSelected:(BOOL)isSelected needCallBack:(BOOL)needCallBack;  //for radio\multi-select


@end

@protocol MGKeyowrdsViewDelegate <NSObject>

-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didClickedWithIndex:(NSInteger)index item:(MGKeyowrdsViewItem *)item;
-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didRadioedWithIndex:(NSInteger)index item:(MGKeyowrdsViewItem *)item;
-(void)mg_keywordsView:(MGKeyowrdsView *)keyWordsView didMultiselectChangedWithItems:(NSArray<MGKeyowrdsViewItem *> *)selectedItems;    //may return empty array

@end



@interface MGKeyowrdsViewItem : NSObject

@property (copy, nonatomic)     NSString *  title;
@property (assign, nonatomic)   BOOL        selected;   //是否选中(radio or multi-select)

@property (strong, nonatomic)   id          sender;     //业务层需要的参数 可不写

@end



