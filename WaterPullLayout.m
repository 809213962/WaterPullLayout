//
//  WaterPullLayout.m
//  04-自定义的瀑布流
//
//  Created by lin on 16/9/20.
//  Copyright © 2016年 林理刚. All rights reserved.
//

#import "WaterPullLayout.h"

@interface WaterPullLayout ()

/**
 *  保存每列的总高度
 */
@property (nonatomic, strong) NSMutableArray *columnHeightArray;

/**
 *  保存cell详细信息
 */
@property (nonatomic, strong) NSMutableArray *itemAttributes;

@end

@implementation WaterPullLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //默认是2列
        _column = 2;
        _sectionInsets = UIEdgeInsetsZero;
        _interitemSpacing = 10;
        _lineSpacing = 10;
    }
    return self;
}

/**
 *  返回高度最小的列
 *
 *  @return <#return value description#>
 */
- (NSUInteger)minIndexFromColumnHeightArray
{
    __block NSUInteger minIndex = 0;
    //min=MAXFLOAT目的为了保证第一个值一定为最小值
    __block CGFloat min = MAXFLOAT;
    
    //遍历
    [_columnHeightArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //如果当前数组中有比当前最小值还小的数，说明当前这个数就是最小值
        if (min > [obj floatValue])
        {
            //保存最小值
            min = [obj floatValue];
            //保存最下值的索引
            minIndex = idx;
        }
    }];
    
    return minIndex;
}

/**
 *  返回高度最大的列
 *
 *  @return <#return value description#>
 */
- (NSUInteger)maxIndexFromColumnHeightArray
{
    __block NSUInteger maxIndex = 0;
    //min=MAXFLOAT目的为了保证第一个值一定为最小值
    __block CGFloat max = 0;
    
    //遍历
    [_columnHeightArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //如果当前数组中有比当前最小值还小的数，说明当前这个数就是最小值
        if (max < [obj floatValue])
        {
            //保存最小值
            max = [obj floatValue];
            //保存最下值的索引
            maxIndex = idx;
        }
    }];
    
    return maxIndex;
}

/**
 *  1.布局cell的。如果调用collectionView的reloadData方法就会触发该方法
 */
- (void)prepareLayout
{
    self.delegate = (id<WaterPullLayoutDelegate>)self.collectionView.delegate;
    
    //初始化数组
    _columnHeightArray = [NSMutableArray array];
    _itemAttributes = [NSMutableArray array];
    
    //添加默认值,每列高度默认是0
    for (int i = 0; i < self.column; i++)
    {
        [_columnHeightArray addObject:@(0)];
    }
    
    /*
     对每个cell位置进行计算
     */
    //cell的x
    CGFloat xOffset;
    //cell的y
    CGFloat yOffset;
    //cell的宽度
    CGFloat itemWidth;
    //cell的高度
    CGFloat itemHeight;
    
    
    //cell的宽度 = (collectionView的宽度 - 左边 - 右边 - cell的空隙)/列数
    itemWidth = (self.collectionView.frame.size.width - self.sectionInsets.left - self.sectionInsets.right - _interitemSpacing*(_column - 1))/_column;
    
    //获取当前组的个数
    //[self.collectionView numberOfSections];
    //获取指定组的cell的个数
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    //遍历每一个cell,分别计算x,y,width,height
    for (int i = 0; i < numberOfItems; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        //获取cell的大小
        CGSize size = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        /*
         原始H       X
        ------  =  -----  ===>  X = 原始H * 现在W / 原始W
         原始W      现在W
         */
        itemHeight = size.height * itemWidth / size.width;
        
        //先获取最小列的index
        NSUInteger minIndex = [self minIndexFromColumnHeightArray];
        
        //x
        xOffset = _sectionInsets.left + minIndex * (itemWidth + _interitemSpacing);
        
        //y
        yOffset = (i < _column) ? _sectionInsets.top : ([_columnHeightArray[minIndex] floatValue] + _lineSpacing);
        

        
        //创建一个item的attribute对象
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        //当前cell坐标
        attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
        
        //保存cell的信息
        [self.itemAttributes addObject:attributes];
        
        
        //修改数组的当前最小列的总高度
        _columnHeightArray[minIndex] = @(CGRectGetMaxY(attributes.frame));
        
    }
    
}

/**
 *  2.返回指定范围的cell的布局的详细信息
 *
 *  @param rect <#rect description#>
 *
 *  @return <#return value description#>
 */
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.itemAttributes;
}

/**
 *  3.返回指定的cell的详细布局信息
 *
 *  @param indexPath <#indexPath description#>
 *
 *  @return <#return value description#>
 */
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemAttributes[indexPath.item];
}

/**
 *  4.重新计算当前滚动视图的contentSize
 *
 *  @return <#return value description#>
 */
- (CGSize)collectionViewContentSize
{
    //获取最大列的index
    NSUInteger maxIndex = [self maxIndexFromColumnHeightArray];
    
    return CGSizeMake(self.collectionView.frame.size.width, [_columnHeightArray[maxIndex] floatValue] + _sectionInsets.bottom);
}

@end
