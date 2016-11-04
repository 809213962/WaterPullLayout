//
//  WaterPullLayout.h
//  04-自定义的瀑布流
//
//  Created by vera on 16/9/20.
//  Copyright © 2016年 林理刚. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WaterPullLayoutDelegate <NSObject>

@required
/**
 *  返回cell的大小
 *
 *  @param collectionView       <#collectionView description#>
 *  @param collectionViewLayout <#collectionViewLayout description#>
 *  @param indexPath            <#indexPath description#>
 *
 *  @return <#return value description#>
 */

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface WaterPullLayout : UICollectionViewLayout

@property (nonatomic, weak) id<WaterPullLayoutDelegate> delegate;

/**
 *  列数， 默认是2列
 */
@property (nonatomic, assign) NSInteger column;

/**
 *  距离上下左右的距离
 */
@property (nonatomic, assign) UIEdgeInsets sectionInsets;

/**
 *  上下两个item的距离
 */
@property (nonatomic, assign) CGFloat lineSpacing;

/**
 *  左右两个item的距离
 */
@property (nonatomic, assign) CGFloat interitemSpacing;

@end
