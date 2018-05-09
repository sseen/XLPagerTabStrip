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
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            let buttonBarHeight = 44
            let buttonBar = OnlyButtonBarView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.size.width), height: buttonBarHeight), collectionViewLayout: flowLayout)
            buttonBar.selectedBar.backgroundColor = .orange
            buttonBar.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
            buttonBar.autoresizingMask = .flexibleWidth
            
            return buttonBar
            }()
        buttonBarView = buttonBarViewAux
        
        if buttonBarView.superview == nil {
            view.addSubview(buttonBarView)
        }
        if buttonBarView.delegate == nil {
            buttonBarView.delegate = self
        }
        if buttonBarView.dataSource == nil {
            buttonBarView.dataSource = self
        }
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = buttonBarView.settings.style.buttonBarMinimumInteritemSpacing ?? flowLayout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = buttonBarView.settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top, left: buttonBarView.settings.style.buttonBarLeftContentInset ?? sectionInset.left, bottom: sectionInset.bottom, right: buttonBarView.settings.style.buttonBarRightContentInset ?? sectionInset.right)
        
        buttonBarView.showsHorizontalScrollIndicator = false
        
        // register button bar item cell
        switch buttonBarView.buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"Cell")
        case .cellClass:
            buttonBarView.register(ButtonBarViewCell.self, forCellWithReuseIdentifier:"Cell")
        }
        
        self.view.addSubview(buttonBarView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
