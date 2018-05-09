//
//  OnlyButtonBarViewController.swift
//  Example
//
//  Created by sseen on 2018/5/9.
//

import UIKit
import XLPagerTabStrip

class OnlyButtonBarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var buttonBarView: OnlyButtonBarView!
    
    var content = ["wheoweojr", "nihaodaoie", "hwoeo", "joadshoa", "hello", "bye"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let buttonBarViewAux = buttonBarView ?? {
            let buttonBarHeight = 44
            let buttonBar = OnlyButtonBarView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.size.width), height: buttonBarHeight), collectionViewLayout: nil, content: content)
            
            return buttonBar
            }()
        buttonBarView = buttonBarViewAux

        buttonBarView.delegate = self
        buttonBarView.dataSource = self
        
        self.view.addSubview(buttonBarView)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Force the UICollectionViewFlowLayout to get laid out again with the new size if
        // a) The view is appearing.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called for a second time
        //    when the view is shown and when the view *frame(s)* are actually set
        //    (we need the view frame's to have been set to work out the size's and on the
        //    first call to collectionView:layout:sizeForItemAtIndexPath: the view frame(s)
        //    aren't set correctly)
        // b) The view is rotating.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called again and can use the views
        //    *new* frame so that the buttonBarView cell's actually get resized correctly
//        cachedCellWidths = calculateWidths()
//        buttonBarView.collectionViewLayout.invalidateLayout()
        // When the view first appears or is rotated we also need to ensure that the barButtonView's
        // selectedBar is resized and its contentOffset/scroll is set correctly (the selected
        // tab/cell may end up either skewed or off screen after a rotation otherwise)
        
        buttonBarView.moveTo(index: buttonBarView.currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
        buttonBarView.selectItem(at: IndexPath(item: buttonBarView.currentIndex, section: 0), animated: false, scrollPosition: [])
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let cellWidthValue = buttonBarView.cachedCellWidths?[indexPath.row] else {
            fatalError("cachedCellWidths for \(indexPath.row) must not be nil")
        }
        return CGSize(width: cellWidthValue, height: collectionView.frame.size.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != buttonBarView.currentIndex else { return }
        
        buttonBarView.moveTo(index: indexPath.item, animated: true, swipeDirection: .none, pagerScroll: .yes)
        //shouldUpdateButtonBarView = false
        
        let oldIndexPath = IndexPath(item: buttonBarView.currentIndex, section: 0)
        let newIndexPath = IndexPath(item: indexPath.item, section: 0)
        
        let cells = buttonBarView.cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: true)
        
        if buttonBarView.pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = buttonBarView.changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(cells.first!, cells.last!, 1, true, true)
            }
        } else {
            if let changeCurrentIndex = buttonBarView.changeCurrentIndex {
                changeCurrentIndex(cells.first!, cells.last!, true)
            }
        }
        buttonBarView.currentIndex = indexPath.item
        //moveToViewController(at: indexPath.item)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ButtonBarViewCell else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        
        
        let indicatorInfo = IndicatorInfo(title: "title")
        
        cell.label.text = content[indexPath.item]
        cell.accessibilityLabel = content[indexPath.item]
        cell.label.font = buttonBarView.settings.style.buttonBarItemFont
        cell.label.textColor = buttonBarView.settings.style.buttonBarItemTitleColor ?? cell.label.textColor
        cell.contentView.backgroundColor = buttonBarView.settings.style.buttonBarItemBackgroundColor ?? cell.contentView.backgroundColor
        cell.backgroundColor = buttonBarView.settings.style.buttonBarItemBackgroundColor ?? cell.backgroundColor
        if let image = indicatorInfo.image {
            cell.imageView.image = image
        }
        if let highlightedImage = indicatorInfo.highlightedImage {
            cell.imageView.highlightedImage = highlightedImage
        }
        
        // ssn configureCell(cell, indicatorInfo: indicatorInfo)
        
        if buttonBarView.pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = buttonBarView.changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(buttonBarView.currentIndex == indexPath.item ? nil : cell, buttonBarView.currentIndex == indexPath.item ? cell : nil, 1, true, false)
            }
        } else {
            if let changeCurrentIndex = buttonBarView.changeCurrentIndex {
                changeCurrentIndex(buttonBarView.currentIndex == indexPath.item ? nil : cell, buttonBarView.currentIndex == indexPath.item ? cell : nil, false)
            }
        }
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = cell.label.text
        cell.accessibilityTraits |= UIAccessibilityTraitButton
        cell.accessibilityTraits |= UIAccessibilityTraitHeader
        return cell
    }
    

    @IBAction func ckBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
