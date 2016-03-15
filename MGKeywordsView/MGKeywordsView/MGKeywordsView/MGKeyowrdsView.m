//
//  MGKeyowrdsView.m
//  MGKeywordsView
//
//  Created by Marves Guo on 16/3/11.
//  Copyright © 2016年 Marves Guo. All rights reserved.
//

#import "MGKeyowrdsView.h"
//#import "NSString+SizeToFit.h"

#define __keywords_collection_view_index_to_tag(index) (index + 1000)
#define __keywords_collection_view_tag_to_index(tag)   (tag - 1000)


typedef NS_ENUM(NSInteger, ActionType) {
    ActionTypeNone = 0,    //只是展示
    ActionTypeClick,       //按钮
    ActionTypeRadio,       //单选
    ActionTypeMultiselect, //多选
};

typedef NS_ENUM(NSInteger, ShowType) {
    ShowTypeDefault = 0,        //展示不下换行，不拉伸
    ShowTypeAspectFill,         //展示不下换行，拉伸 不留空
};


@interface MGKeyowrdsView ()
{
    
    NSArray *_items;
    NSArray *_dataSource;   //根据UI处理后的数据源展现用
    
    MGKeyowrdsViewType _type;
    
    ActionType _actionType;
    ShowType _showType;
    
    CGFloat _maxWidth;
    NSInteger _numberOfLines;          //当前传入
    NSInteger _totalNumberOfLines;     //共计
    
    CGFloat _topMargin;
    CGFloat _bottomMargin;
    CGFloat _leftMargin;
    CGFloat _rightMargin;
    
    CGFloat _itemsHorizontalSpace;   //上下两行间距
    CGFloat _itemsVerticalSpace;     //左右两间距
    CGFloat _itemInnerLeftSpace;      //字距描边的距离
    CGFloat _itemInnerRightSpace;
    
    CGFloat _itemHeight;
    
    UIFont *_textFont;
    UIColor *_itemBackgroundColor;
    
    CGFloat _borderWidth;
    CGFloat _cornerRadius;
    
    //normal
    UIColor *_textColor;
    UIColor *_borderColor;
    NSString *_normalImagePath;          //背景图 （不含描边）
    UIEdgeInsets _normalImageCapInsets;
    
    //highlighted
    UIColor *_highLightedTextColor;
    NSString *_highLightedImagePath;     //高亮图 （不含描边）
    UIEdgeInsets _highLightedImageCapInsets;
    
    //selected
    UIColor *_selectedTextColor;
    UIColor *_selectedBorderColor;
    NSString *_selectedImagePath;        //选中图 （不含描边）
    UIEdgeInsets _selectedImageCapInsets;
    
    NSInteger _lastSelectIndex;        //For Radio
    NSMutableSet *_selectedSet;        //For Multiselect
    
}


- (void)p_configSettingWithType:(MGKeyowrdsViewType)type;
- (void)p_initSubviews;

- (NSArray<NSArray<NSString *>*> *)p_dealItemsToDataSource:(NSArray<MGKeyowrdsViewItem *> *)items numberOfLines:(NSInteger)numberOfLines;
- (CGFloat)p_itemWidthWithString:(NSString *)string;
- (CGFloat)p_calculateHeightWithNumberOfLines:(NSInteger) numberOfLines;


@end


@implementation MGKeyowrdsView

#pragma mark - life cycle

- (instancetype)initWithItems:(NSArray *)items maxWidth:(CGFloat)maxWidth numberOfLines:(NSInteger)numberOfLines type:(MGKeyowrdsViewType)type {
    
    if (self = [super init])
    {
        _items = items;
        _type = type;
        
        _maxWidth = maxWidth;
        _numberOfLines = numberOfLines;
        
        [self p_configSettingWithType:type];
        
        if (_items.count > 0 && maxWidth > 0)
        {
            _dataSource = [self p_dealItemsToDataSource:_items numberOfLines:0];
            _totalNumberOfLines = _dataSource.count;
            if (_numberOfLines <= 0 || _numberOfLines > _totalNumberOfLines)
                _numberOfLines = _totalNumberOfLines;
            
            [self p_initSubviews];
        }
    }
    return self;
}


#pragma mark - event response

-(void)itemClickAction:(UIButton *)btn
{
    switch (_actionType) {
        case ActionTypeNone:
        {
            // nothing
        }
            break;
            
        case ActionTypeClick:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(mg_keywordsView:didClickedWithIndex:item:)])
            {
                [self.delegate mg_keywordsView:self didClickedWithIndex:__keywords_collection_view_tag_to_index(btn.tag)  item:[_items objectAtIndex:__keywords_collection_view_tag_to_index(btn.tag)]];
            }
        }
            break;
            
        case ActionTypeRadio:
        {
            MGKeyowrdsViewItem *item = [_items objectAtIndex:__keywords_collection_view_tag_to_index(btn.tag)];
            MGKeyowrdsViewItem *lastSelectedItem ;
            if (_lastSelectIndex >= 0) 
                lastSelectedItem = [_items objectAtIndex:_lastSelectIndex];
            
            
            if (item.selected)  //--->非选中
            {
                btn.selected = NO;
                item.selected = NO;
                btn.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                _lastSelectIndex = -1;
            }
            else    //--->选中
            {
                if (lastSelectedItem)
                {
                    UIButton *lastSelectedButton = (UIButton *)[self viewWithTag:__keywords_collection_view_index_to_tag(_lastSelectIndex)];
                    lastSelectedButton.selected = NO;
                    lastSelectedItem.selected = NO;
                    lastSelectedButton.layer.borderColor = lastSelectedItem.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                    _lastSelectIndex = -1;
                }
                btn.selected = YES;
                item.selected = YES;
                btn.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                _lastSelectIndex = __keywords_collection_view_tag_to_index(btn.tag);
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(mg_keywordsView:didRadioedWithIndex:item:)])
                {
                    [self.delegate mg_keywordsView:self didRadioedWithIndex:_lastSelectIndex item:[_items objectAtIndex:_lastSelectIndex]];
                }
            }
        }
            break;
            
        case ActionTypeMultiselect:
        {
            
            MGKeyowrdsViewItem *item = [_items objectAtIndex:__keywords_collection_view_tag_to_index(btn.tag)];
            
            if ([_selectedSet containsObject:item])  //----->非选中
            {
                btn.selected = NO;
                item.selected = NO;
                btn.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                [_selectedSet removeObject:item];
            }
            else   //－－－－－－> 选中
            {
                btn.selected = YES;
                item.selected = YES;
                btn.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                [_selectedSet addObject:item];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(mg_keywordsView:didMultiselectChangedWithItems:)])
            {
                [self.delegate mg_keywordsView:self didMultiselectChangedWithItems:[_selectedSet allObjects]];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - public methods


+ (instancetype)keywordsViewWithType:(MGKeyowrdsViewType)type maxWidth:(CGFloat)maxWidth items:(NSArray<MGKeyowrdsViewItem *> *)items  numberOfLines:(NSInteger)numberOfLines {
    
    return [[MGKeyowrdsView alloc]initWithItems:items maxWidth:maxWidth numberOfLines:numberOfLines type:type];
}


//+ (CGFloat) heightWithNumberOfLines:(NSInteger)numberOfLines maxWidth:(CGFloat)maxWidth type:(MGKeyowrdsViewType)type {
//    
//    MGKeyowrdsView *keywordsView = [MGKeyowrdsView keywordsViewWithType:nil maxWidth:maxWidth numberOfLines:numberOfLines type:type];
//    return [keywordsView p_calculateHeightWithNumberOfLines:numberOfLines];
//}

- (CGFloat)refreshForNumberOfLines:(NSInteger)lines {
    
    if (lines <= 0 || lines > _totalNumberOfLines)
        lines = _totalNumberOfLines;
    
    if (lines != _numberOfLines)
    {
        _numberOfLines = lines;
        
        self.frame = CGRectMake(0, 0, _maxWidth, _topMargin + _numberOfLines * (_itemHeight + _itemsVerticalSpace) - _itemsVerticalSpace + _bottomMargin);
        
        for (UIView *subView in self.subviews)
            subView.hidden = (subView.frame.origin.y + subView.frame.size.height) > self.frame.size.height;
    }
    return self.frame.size.height;
}


- (void)setItemSelectedAtIndex:(NSInteger)index isSelected:(BOOL)isSelected needCallBack:(BOOL)needCallBack{
    
    if (index < 0 || index >= _items.count)
        return;
    
    // 单选
    if (_actionType == ActionTypeRadio)
    {
        MGKeyowrdsViewItem *item = [_items objectAtIndex:index];
        MGKeyowrdsViewItem *lastSelectedItem = [_items objectAtIndex:_lastSelectIndex];
        
        if (isSelected) {   //－－－－－－>选中
            
            if (item.selected == isSelected) {  //当前选中 不用处理
                
                if (needCallBack && self.delegate && [self.delegate respondsToSelector:@selector(mg_keywordsView:didRadioedWithIndex:item:)])
                {
                    [self.delegate mg_keywordsView:self didRadioedWithIndex:_lastSelectIndex item:[_items objectAtIndex:_lastSelectIndex]];
                }
                return;
            }
            else
            {
                if (lastSelectedItem)     //有其它选中－－－－－>选中
                {
                    
                    UIButton *lastSelectedButton = [self viewWithTag:__keywords_collection_view_index_to_tag(_lastSelectIndex)];
                    lastSelectedButton.selected = NO;
                    lastSelectedItem.selected = NO;
                    lastSelectedButton.layer.borderColor = lastSelectedItem.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                    _lastSelectIndex = -1;
                }
                
                UIButton *selectedButton = [self viewWithTag:__keywords_collection_view_index_to_tag(index)];
                selectedButton.selected = YES;
                item.selected = YES;
                selectedButton.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                _lastSelectIndex = index;
                
                if (needCallBack && self.delegate && [self.delegate respondsToSelector:@selector(mg_keywordsView:didRadioedWithIndex:item:)])
                {
                    [self.delegate mg_keywordsView:self didRadioedWithIndex:_lastSelectIndex item:[_items objectAtIndex:_lastSelectIndex]];
                }
            }
        }
        else
        {
            UIButton *selectedButton = [self viewWithTag:__keywords_collection_view_index_to_tag(index)];
            selectedButton.selected = NO;
            item.selected = NO;
            selectedButton.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
            _lastSelectIndex = -1;
        }
    }
    
    //多选
    if (_actionType == ActionTypeMultiselect)
    {
        MGKeyowrdsViewItem *item = [_items objectAtIndex:index];
        UIButton *selectedButton = [self viewWithTag:__keywords_collection_view_index_to_tag(index)];
        
        if ([_selectedSet containsObject:item] && !isSelected)    //----->非选中
        {
            selectedButton.selected = NO;
            item.selected = NO;
            selectedButton.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
            [_selectedSet removeObject:item];
            
            if (needCallBack && self.delegate && [self.delegate respondsToSelector:@selector(mg_keywordsView:didMultiselectChangedWithItems:)])
            {
                [self.delegate mg_keywordsView:self didMultiselectChangedWithItems:[_selectedSet allObjects]];
            }
        }
        
        if (![_selectedSet containsObject:item] && isSelected)   //－－－－－－> 选中
        {
            selectedButton.selected = YES;
            item.selected = YES;
            selectedButton.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
            [_selectedSet addObject:item];
            
            if (needCallBack && self.delegate && [self.delegate respondsToSelector:@selector(mg_keywordsView:didMultiselectChangedWithItems:)])
            {
                [self.delegate mg_keywordsView:self didMultiselectChangedWithItems:[_selectedSet allObjects]];
            }
        }
    }
}

- (NSInteger)currentNumberOfLines {
    
    return _numberOfLines;
}


- (NSInteger)noLimitedNumberOfLines{
    
    return [[self p_dealItemsToDataSource:_items numberOfLines:0] count];
}

- (CGFloat)heightWithNumberOfLines:(NSInteger) numberOfLines {
    
    if ( numberOfLines < 0 || numberOfLines > _dataSource.count)
    {
        numberOfLines = 0;
    }
    
    NSInteger calculateLines = numberOfLines == 0 ? _dataSource.count : numberOfLines;
    
    return  _topMargin + calculateLines * (_itemHeight + _itemsVerticalSpace) - _itemsVerticalSpace + _bottomMargin;
}


#pragma mark - private methods
//各业务类型在这修改需要的UI参数
- (void)p_configSettingWithType:(MGKeyowrdsViewType)type {
    
    switch (type) {
            
        case MGKeyowrdsViewTypeDefault:
        {
            _actionType = ActionTypeNone;
            _showType = ShowTypeDefault;
            
            _topMargin = 15;
            _bottomMargin = 15;
            _leftMargin = 15;
            _rightMargin = 5;
            
            _itemsHorizontalSpace = 10;
            _itemsVerticalSpace = 10;
            _itemInnerLeftSpace = 8;
            _itemInnerRightSpace = 8;
            
            _itemHeight = 25.f;
            
            _textFont = [UIFont systemFontOfSize:12.f];
            _itemBackgroundColor = [UIColor whiteColor];
            _borderWidth = 0.5;
            _cornerRadius = 3;
            
            _textColor = [self colorWithHex:0x646464 alpha:1];
            _borderColor = [self colorWithHex:0xdcdcdc alpha:1];
            self.backgroundColor = [UIColor whiteColor];
        }
            break;
            
        case MGKeyowrdsViewTypeExampleClick:
        {
            
            _actionType = ActionTypeClick;
            _showType = ShowTypeDefault;
            
            _topMargin = 15;
            _bottomMargin = 15;
            _leftMargin = 15;
            _rightMargin = 5;
            
            _itemsHorizontalSpace = 10;
            _itemsVerticalSpace = 5;
            _itemInnerLeftSpace = 8;
            _itemInnerRightSpace = 8;
            
            _itemHeight = 25.f;
            
            _textFont = [UIFont systemFontOfSize:12.f];
            _itemBackgroundColor = [UIColor whiteColor];
            _borderWidth = 0.5;
            _cornerRadius = 3;
            
            _textColor = [self colorWithHex:0x646464 alpha:1];
            _borderColor = [self colorWithHex:0xdcdcdc alpha:1];
            
            self.backgroundColor = [UIColor whiteColor];
        }
            break;
            
        case MGKeyowrdsViewTypeExampleClickAspectFill:
        {
            _actionType = ActionTypeClick;
            _showType = ShowTypeAspectFill;
            
            _topMargin = 15;
            _bottomMargin = 15;
            _leftMargin = 15;
            _rightMargin = 15;
            
            _itemsHorizontalSpace = 4;
            _itemsVerticalSpace = 5;
            _itemInnerLeftSpace = 9;
            _itemInnerRightSpace = 9;
            
            _itemHeight = 25.f;
            
            
            _textFont = [UIFont systemFontOfSize:13.f];
            _itemBackgroundColor = [self colorWithHex:0xd2e6ff alpha:1];
            _borderWidth = 0;
            _cornerRadius = 0;
            self.backgroundColor = [UIColor whiteColor];
            
            _textColor = [self colorWithHex:0x006ec8 alpha:1];
            
            _highLightedTextColor = [self colorWithHex:0x006ec8 alpha:1];
        }
            break;
            
        case MGKeyowrdsViewTypeExampleRadio:
        {
            
            _actionType = ActionTypeRadio;
            _showType = ShowTypeDefault;
            
            _topMargin = 15;
            _bottomMargin = 15;
            _leftMargin = 15;
            _rightMargin = 15;
            
            _itemsHorizontalSpace = 10;
            _itemsVerticalSpace = 10;
            _itemInnerLeftSpace = 8;
            _itemInnerRightSpace = 8;
            
            _itemHeight = 30.f;
            
            _textFont = [UIFont systemFontOfSize:12.f];
            _itemBackgroundColor = [UIColor whiteColor];
            _borderWidth = 0.5;
            _cornerRadius = 3;
            self.backgroundColor = [UIColor whiteColor];
            
            _textColor = [self colorWithHex:0x969696 alpha:1];
            _borderColor = [self colorWithHex:0xdcdcdc alpha:1];
            
            _highLightedTextColor = [self colorWithHex:0x4ba2ed alpha:1];
            _highLightedImagePath = @"btn_category_highLighted";
            _highLightedImageCapInsets = UIEdgeInsetsMake(6, 6, 6, 6);
            
            _selectedTextColor = [self colorWithHex:0x4ba2ed alpha:1];
            _selectedBorderColor = [self colorWithHex:0x4ba2ed alpha:1];
            _selectedImagePath = @"icon_btn_category_selected";
            _selectedImageCapInsets = UIEdgeInsetsMake(0, 0, 14, 14);
        }
            break;
      
            
        case MGKeyowrdsViewTypeExampleMultiSelect:
        {
            
            _actionType = ActionTypeMultiselect;
            _showType = ShowTypeDefault;
            
            _topMargin = 15;
            _bottomMargin = 15;
            _leftMargin = 15;
            _rightMargin = 15;
            
            _itemsHorizontalSpace = 10;
            _itemsVerticalSpace = 10;
            _itemInnerLeftSpace = 8;
            _itemInnerRightSpace = 8;
            
            _itemHeight = 30.f;
            
            _textFont = [UIFont systemFontOfSize:12.f];
            _itemBackgroundColor = [UIColor whiteColor];
            _borderWidth = 0.5;
            _cornerRadius = 3;
            self.backgroundColor = [UIColor whiteColor];
            
            _textColor = [self colorWithHex:0x969696 alpha:1];
            _borderColor = [self colorWithHex:0xdcdcdc alpha:1];
            
            _highLightedTextColor = [self colorWithHex:0x4ba2ed alpha:1];
            _highLightedImagePath = @"btn_category_highLighted";
            _highLightedImageCapInsets = UIEdgeInsetsMake(6, 6, 6, 6);
            
            _selectedTextColor = [self colorWithHex:0x4ba2ed alpha:1];
            _selectedBorderColor = [self colorWithHex:0x4ba2ed alpha:1];
            _selectedImagePath = @"icon_btn_category_selected";
            _selectedImageCapInsets = UIEdgeInsetsMake(0, 0, 14, 14);
            
            self.backgroundColor = [UIColor whiteColor];
        }
            break;
        default:
            break;
    }
}

- (void)p_initSubviews {
    
    self.frame = CGRectMake(0, 0, _maxWidth, _topMargin + _numberOfLines * (_itemHeight + _itemsVerticalSpace) - _itemsVerticalSpace + _bottomMargin);
    
    _lastSelectIndex = -1;
    
    __block NSInteger buttonTag = __keywords_collection_view_index_to_tag(0);  //tag 相当于数组的下标
    
    [_dataSource enumerateObjectsUsingBlock:^(id  obj1, NSUInteger idx1, BOOL * stop1) {
        
        if ([obj1 isKindOfClass:[NSArray class]])
        {
            NSArray *itemsOneLine = (NSArray *)obj1;
            
            __block CGFloat currentX = _leftMargin;
            
            CGFloat extraWidth = 0;
            
            if (_showType == ShowTypeAspectFill)
            {
                __block CGFloat totalItemsWidth = 0;
                [itemsOneLine enumerateObjectsUsingBlock:^(id  obj2, NSUInteger idx2, BOOL * stop2) {
                    NSString *title = (NSString *)obj2;
                    totalItemsWidth += [self p_itemWidthWithString:title];
                }];
                totalItemsWidth += _itemsHorizontalSpace * (itemsOneLine.count - 1);
                
                extraWidth =  (_maxWidth -_leftMargin -_rightMargin - totalItemsWidth) / itemsOneLine.count;
                MAX(0, extraWidth);
            }
            
            [itemsOneLine enumerateObjectsUsingBlock:^(id  obj2, NSUInteger idx2, BOOL * stop2) {
                
                if ([obj2 isKindOfClass:[NSString class]])
                {
                    NSString *title = (NSString *)obj2;
                    
                    CGFloat itemWidth = [self p_itemWidthWithString:title] + extraWidth;
                    
                    CGRect itemRect = CGRectMake(currentX,
                                                 _topMargin + idx1 * (_itemHeight + _itemsVerticalSpace),
                                                 itemWidth,
                                                 _itemHeight);
                    
                    UIImage *normalImage = [[UIImage imageNamed:_normalImagePath] resizableImageWithCapInsets:_normalImageCapInsets];
                    UIImage *highLightImage = [[UIImage imageNamed:_highLightedImagePath] resizableImageWithCapInsets:_highLightedImageCapInsets];
                    UIImage *selectedImage = [[UIImage imageNamed:_selectedImagePath] resizableImageWithCapInsets:_selectedImageCapInsets];
                    
                    
                    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    aButton.frame = itemRect;
                    
                    aButton.layer.borderColor = _borderColor.CGColor;
                    aButton.layer.cornerRadius = _cornerRadius;
                    aButton.layer.borderWidth = _borderWidth;
                    
                    [aButton setBackgroundImage:normalImage forState:UIControlStateNormal];
                    [aButton setBackgroundImage:highLightImage forState:UIControlStateHighlighted];
                    [aButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
                    
                    aButton.backgroundColor = _itemBackgroundColor;
                    
                    aButton.titleEdgeInsets = UIEdgeInsetsMake(0,_itemInnerLeftSpace,0,_itemInnerRightSpace);
                    
                    aButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
                    if (_type == MGKeyowrdsViewTypeExampleClickAspectFill)
                        aButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

                    aButton.titleLabel.font = _textFont;
                    [aButton setTitle:title forState:UIControlStateNormal];
                    [aButton setTitleColor:_textColor forState:UIControlStateNormal];
                    [aButton setTitleColor:_highLightedTextColor forState:UIControlStateHighlighted];
                    [aButton setTitleColor:_selectedTextColor forState:UIControlStateSelected];
                    
                    [aButton addTarget:self action:@selector(itemClickAction:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:aButton];
                    
                    
                    currentX += aButton.frame.size.width + _itemsHorizontalSpace;
                    
                    aButton.tag = buttonTag;
                    aButton.enabled = _actionType != ActionTypeNone;
                    if (idx1 >= _numberOfLines)
                        aButton.hidden = YES;
                    
                    MGKeyowrdsViewItem *item = [_items objectAtIndex:__keywords_collection_view_tag_to_index(buttonTag)];
                    if (_actionType == ActionTypeRadio)
                    {
                        aButton.selected = item.selected;
                        if (item.selected)
                            _lastSelectIndex = __keywords_collection_view_tag_to_index(buttonTag);
                        
                        aButton.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                    }
                    
                    if (_actionType == ActionTypeMultiselect)
                    {
                        _selectedSet = [NSMutableSet set];
                        
                        aButton.selected = item.selected;
                        if (item.selected) {
                            [_selectedSet addObject:item];
                        }
                        aButton.layer.borderColor = item.selected ? _selectedBorderColor.CGColor : _borderColor.CGColor;
                    }
                    buttonTag++;
                }
            }];
        }
    }];
}

//  @return
//  @[
//      @[@"xxxxx",@"sssss"],
//      @[@"xxxxxxxxxxxxxx"]
//    ]
- (NSArray<NSArray<NSString *>*> *)p_dealItemsToDataSource:(NSArray<MGKeyowrdsViewItem *> *)items numberOfLines:(NSInteger)numberOfLines
{
    __block NSMutableArray *resultItems = [NSMutableArray array];
    
    __block NSMutableArray *currentLineArray = [NSMutableArray array];
    __block CGFloat currentWith = 0;
    
    
    [items enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        
        if ([obj isKindOfClass:[MGKeyowrdsViewItem class]])
        {
            MGKeyowrdsViewItem *item = (MGKeyowrdsViewItem *)obj;
            
            CGFloat itemWidth = [self p_itemWidthWithString:item.title];
            //在本行
            if (currentWith + itemWidth <= (_maxWidth - _leftMargin - _rightMargin))
            {
                currentWith += itemWidth + _itemsHorizontalSpace;
                [currentLineArray addObject:item.title];
            }
            else //换行
            {
                [resultItems addObject:[NSArray arrayWithArray:currentLineArray]];
                [currentLineArray removeAllObjects];
                currentWith = 0;
                
                //下一行第一个
                currentWith += itemWidth + _itemsHorizontalSpace;
                [currentLineArray addObject:item.title];
            }
            
            if (resultItems.count > numberOfLines && numberOfLines > 0)  //够了
            {
                [resultItems removeLastObject];
                *stop = YES;
            }
        }
    }];
    
    if (currentLineArray.count > 0 && ((resultItems.count < numberOfLines && numberOfLines > 0) || numberOfLines <= 0))
    {
        [resultItems addObject:currentLineArray];
    }
    return [NSArray arrayWithArray:resultItems];
}


- (CGFloat)p_itemWidthWithString:(NSString *)string {
    
    CGFloat maxItemWidth = _maxWidth - _leftMargin - _rightMargin - _itemInnerLeftSpace - _itemInnerRightSpace;
    
    return [self size2FitWithString:string font:_textFont containerWidth:maxItemWidth lineBreakModel:NSLineBreakByTruncatingMiddle mutableLines:NO].width + _itemInnerLeftSpace + _itemInnerRightSpace;
}

- (CGFloat)p_calculateHeightWithNumberOfLines:(NSInteger) numberOfLines { //跟数据源没关系 可无限行
    
    if (numberOfLines < 0)
        numberOfLines = 0;
    
    return  _topMargin + numberOfLines * (_itemHeight + _itemsVerticalSpace) - _itemsVerticalSpace + _bottomMargin;
}



#pragma mark utility methods

- (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hexValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alpha];
}


- (CGSize)size2FitWithString:(NSString *)string font:(UIFont *)font containerWidth:(CGFloat)containerWidth lineBreakModel:(NSLineBreakMode)lienBreakMode  mutableLines:(BOOL)isMutableLines
{
    CGSize size2Fit;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        
        NSDictionary *attribute = @{NSFontAttributeName: font};
        size2Fit = [string sizeWithAttributes:attribute];
        
        if ((size2Fit.width > containerWidth && isMutableLines) || ([string containsString:@"\n"] && isMutableLines)) {
            
            size2Fit = [string boundingRectWithSize : CGSizeMake(containerWidth, CGFLOAT_MAX)
                                          options : NSStringDrawingTruncatesLastVisibleLine |
                        NSStringDrawingUsesLineFragmentOrigin |
                        NSStringDrawingUsesFontLeading
                                       attributes : attribute
                                          context : nil].size;
            
        }
        
        if (size2Fit.width > containerWidth && isMutableLines == NO) {
            size2Fit.width = containerWidth;
        }
        
    }
    else {
        
        size2Fit = [string sizeWithFont:font];
        
        if ((size2Fit.width > containerWidth && isMutableLines) || ([string containsString:@"\n"] && isMutableLines)) {
            
            size2Fit = [string sizeWithFont : font
                        constrainedToSize : CGSizeMake(containerWidth, CGFLOAT_MAX)
                            lineBreakMode : lienBreakMode];
            
        }
        
        if (size2Fit.width > containerWidth && isMutableLines == NO) {
            size2Fit.width = containerWidth;
        }
        
    }
    
    size2Fit.height = ceil(size2Fit.height);
    size2Fit.width = ceil(size2Fit.width);
    
    return size2Fit;
}

@end





#pragma mark - MGKeyowrdsViewItem

@implementation MGKeyowrdsViewItem

@end









