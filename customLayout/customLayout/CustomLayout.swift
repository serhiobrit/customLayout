//
//  CustomLayout.swift
//  customLayout
//
//  Created by Serhio Brit on 17.03.2021.
//

import Foundation
import UIKit

protocol CustomLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGSize
}

class CustomLayout: UICollectionViewFlowLayout {
    
    weak var delegateLayout: CustomLayoutDelegate?
    private let numberOfColumns = 2 // количество столбцов
    
    private let cellPadding: CGFloat = 5 // отступ ячейки по Х
    
    private var cashe: [UICollectionViewLayoutAttributes] = [] // массив для хранения размеры и данные объектов
    
    private var contentHeight: CGFloat = 0 // высота контента
    
    private var contentWidth: CGFloat {                                // вычисляемая ширина
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width
    }
    
    override var collectionViewContentSize: CGSize {                   // размеры ячейки
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {                                          // расстановка контента по ячейкам
        guard cashe.isEmpty, let collectionView = collectionView else { return }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffSet: [CGFloat] = []
        
        for column in 0..<numberOfColumns {
            xOffSet.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        
        var yOffSet: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let imageSize = delegateLayout?.collectionView(collectionView, heightForImageAtIndexPath: indexPath)
            let cellWidth = columnWidth
            var cellHeight = imageSize!.height * cellWidth/imageSize!.width
            cellHeight = cellPadding * 2 + cellHeight
            
            let frame = CGRect(x: xOffSet[column], y: yOffSet[column], width: cellWidth, height: cellHeight)
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes (forCellWith: indexPath)
            attributes.frame = insetFrame
            
            cashe.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            
            yOffSet[column] = yOffSet[column] + cellHeight
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cashe {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cashe[indexPath.item]
    }
    
}

