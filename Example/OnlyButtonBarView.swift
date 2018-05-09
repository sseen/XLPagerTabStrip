//
//  OnlyButtonBarView.swift
//  Example
//
//  Created by sseen on 2018/5/9.
//

import UIKit
import XLPagerTabStrip

class OnlyButtonBarView: ButtonBarView {

    public var settings = ButtonBarPagerTabStripSettings()
    public var buttonBarItemSpec: ButtonBarItemSpec<ButtonBarViewCell>!
    
    public var changeCurrentIndex: ((_ oldCell: ButtonBarViewCell?, _ newCell: ButtonBarViewCell?, _ animated: Bool) -> Void)?
    public var changeCurrentIndexProgressive: ((_ oldCell: ButtonBarViewCell?, _ newCell: ButtonBarViewCell?, _ progressPercentage: CGFloat, _ changeCurrentIndex: Bool, _ animated: Bool) -> Void)?
    
    open var pagerBehaviour = PagerTabStripBehaviour.progressive(skipIntermediateViewControllers: true, elasticIndicatorLimit: true)
    
    open var currentIndex = 0
    
    lazy public var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
        }()
    
    public var content = ["wheoweojr"]
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        myParas()
    }
    
    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout?, content:[String]?) {
        
        if let contents = content {
            self.content = contents
        }
        
        if let layouts = layout {
            super.init(frame: frame, collectionViewLayout: layouts)
        } else {
            let myLayout = UICollectionViewFlowLayout()
            myLayout.scrollDirection = .horizontal
            
            super.init(frame: frame, collectionViewLayout: myLayout)
            
        }
        
        myParas()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func myParas() {
        
        var bundle = Bundle(for: ButtonBarViewCell.self)
        if let resourcePath = bundle.path(forResource: "XLPagerTabStrip", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }
        
        buttonBarItemSpec = .nibFile(nibName: "ButtonCell", bundle: bundle, width: { [weak self] (childItemInfo) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont
            label.text = childItemInfo.title
            let labelSize = label.intrinsicContentSize
            return labelSize.width + (self?.settings.style.buttonBarItemLeftRightMargin ?? 8) * 2
        })
        
        
        self.selectedBar.backgroundColor = UIColor(red:0.00, green:0.62, blue:0.93, alpha:1.00)
        self.backgroundColor = UIColor.white
        // cell title color bg color
        self.settings.style.buttonBarItemBackgroundColor = UIColor.white
        self.settings.style.buttonBarItemTitleColor = UIColor(red:0.133, green:0.133, blue:0.133, alpha:1)
        self.autoresizingMask = .flexibleWidth
        
        self.scrollsToTop = false
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = self.settings.style.buttonBarMinimumInteritemSpacing ?? flowLayout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = self.settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top, left: self.settings.style.buttonBarLeftContentInset ?? sectionInset.left, bottom: sectionInset.bottom, right: self.settings.style.buttonBarRightContentInset ?? sectionInset.right)
        
        self.showsHorizontalScrollIndicator = false
        
        // register button bar item cell
        switch self.buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            self.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"Cell")
        case .cellClass:
            self.register(ButtonBarViewCell.self, forCellWithReuseIdentifier:"Cell")
        }
        
    }
    

    private func calculateWidths() -> [CGFloat] {
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let numberOfCells = content.count
        
        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0
        
        for viewController in content {
            let indicatorInfo = IndicatorInfo(title: viewController)
            switch buttonBarItemSpec! {
            case .cellClass(let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            case .nibFile(_, _, let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            }
        }
        
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        collectionViewContentWidth += cellSpacingTotal
        
        let collectionViewAvailableVisibleWidth = self.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        if !settings.style.buttonBarItemsShouldFillAvailableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth {
            return minimumCellWidths
        } else {
            let stretchedCellWidthIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / CGFloat(numberOfCells)
            let generalMinimumCellWidth = calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: stretchedCellWidthIfAllEqual, previousNumberOfLargeCells: 0)
            var stretchedCellWidths = [CGFloat]()
            
            for minimumCellWidthValue in minimumCellWidths {
                let cellWidth = (minimumCellWidthValue > generalMinimumCellWidth) ? minimumCellWidthValue : generalMinimumCellWidth
                stretchedCellWidths.append(cellWidth)
            }
            
            return stretchedCellWidths
        }
    }
    
    open func calculateStretchedCellWidths(_ minimumCellWidths: [CGFloat], suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0
        
        for minimumCellWidthValue in minimumCellWidths where minimumCellWidthValue > suggestedStretchedCellWidth {
            totalWidthOfLargeCells += minimumCellWidthValue
            numberOfLargeCells += 1
        }
        
        guard numberOfLargeCells > previousNumberOfLargeCells else { return suggestedStretchedCellWidth }
        
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let collectionViewAvailiableWidth = self.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let numberOfCells = minimumCellWidths.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        
        let numberOfSmallCells = numberOfCells - numberOfLargeCells
        let newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / CGFloat(numberOfSmallCells)
        
        return calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: newSuggestedStretchedCellWidth, previousNumberOfLargeCells: numberOfLargeCells)
    }
    
    
    public func cellForItems(at indexPaths: [IndexPath], reloadIfNotVisible reload: Bool = true) -> [ButtonBarViewCell?] {
        let cells = indexPaths.map { self.cellForItem(at: $0) as? ButtonBarViewCell }
        
        if reload {
            let indexPathsToReload = cells.enumerated()
                .compactMap { (arg) -> IndexPath? in
                    let (index, cell) = arg
                    return cell == nil ? indexPaths[index] : nil
                }
                .compactMap { (indexPath: IndexPath) -> IndexPath? in
                    return (indexPath.item >= 0 && indexPath.item < self.numberOfItems(inSection: indexPath.section)) ? indexPath : nil
            }
            
            if !indexPathsToReload.isEmpty {
                self.reloadItems(at: indexPathsToReload)
            }
        }
        
        return cells
    }
}
