
import UIKit
import Photos

public class AssetGrid: UIView {
    
    public var onAssetClick: ((Asset) -> Void)?
    
    public var onSelectedAssetListChange: (() -> Void)?
    
    public var fetchResult: PHFetchResult<PHAsset>! {
        didSet {
            
            assetList = PhotoPickerManager.shared.fetchResult2List(fetchResult: fetchResult, configuration: configuration)
            
            if selectedAssetList.count > 0 {
                selectedAssetList = [Asset]()
            }
            
        }
    }
    
    var assetList = [Asset]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedAssetList = [Asset]() {
        didSet {
            onSelectedAssetListChange?()
        }
    }
    
    private var configuration: PhotoPickerConfiguration!
    
    private let cellIdentifier = "cell"
    
    private var cellSize: CGSize! {
        didSet {
            cellPixelSize = PhotoPickerManager.shared.getPixelSize(size: cellSize)
        }
    }
    
    private var cellPixelSize: CGSize!
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        
        let view = UICollectionViewFlowLayout()
        
        view.scrollDirection = .vertical
        
        return view
        
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let view = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        
        view.register(AssetCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = configuration.assetGridBackgroundColor
        
        addSubview(view)
        
        addConstraints([
            
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            
        ])
        
        return view
        
    }()
    
    public convenience init(configuration: PhotoPickerConfiguration) {
        self.init()
        self.configuration = configuration
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    public func scrollToBottom(animated: Bool) {
        guard assetList.count > 0 else {
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: assetList.count - 1, section: 0), at: .bottom, animated: animated)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        cellSize = getCellSize()
    }

}

extension AssetGrid: UICollectionViewDataSource {
    
    // 获取照片数量
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetList.count
    }
    
    // 复用 cell 组件
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AssetCell
        
        let index = indexPath.item
        let asset = assetList[index]

        asset.index = index
        
        // 选中状态下可以反选
        if asset.order >= 0 {
            asset.selectable = true
        }
        else {
            asset.selectable = selectedAssetList.count < configuration.maxSelectCount
        }
        
        cell.configuration = configuration
        cell.bind(asset: asset, size: cellPixelSize)
        
        cell.onToggleChecked = {
            self.toggleChecked(asset: asset)
        }
        
        return cell
    }
    
}

extension AssetGrid: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assetList[indexPath.item]
        guard asset.selectable else {
            return
        }
        onAssetClick?(asset)
    }
    
}

extension AssetGrid: UICollectionViewDelegateFlowLayout {
    
    // 设置内边距
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: configuration.assetGridPaddingVertical,
            left: configuration.assetGridPaddingHorizontal,
            bottom: configuration.assetGridPaddingVertical,
            right: configuration.assetGridPaddingHorizontal
        )
    }
    
    // 行间距
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return configuration.assetGridRowSpacing
    }
    
    // 列间距
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return configuration.assetGridColumnSpacing
    }
    
    // 设置单元格尺寸
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
}

extension AssetGrid: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            
            if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                fetchResult = changeDetails.fetchResultAfterChanges
            }
            
        }
    }
}

extension AssetGrid {
    
    private func indexPathsForElements(rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = flowLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
    
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        }
        else {
            return ([new], [old])
        }
    }
    
    private func getCellSize() -> CGSize {
        
        let spanCount = configuration.assetGridSpanCount
        
        let paddingHorizontal = configuration.assetGridPaddingHorizontal * 2
        let insetHorizontal = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let gapHorizontal = configuration.assetGridColumnSpacing * (spanCount - 1)
        
        let spacing = paddingHorizontal + insetHorizontal + gapHorizontal
        let width = ((collectionView.frame.width - spacing) / spanCount).rounded(.down)
        
        // 正方形就行
        return CGSize(width: width, height: width)
        
    }
    
    private func toggleChecked(asset: Asset) {
        
        // checked 获取反选值
        let checked = asset.order < 0
        let selectedCount = selectedAssetList.count
        
        if checked {
            
            // 因为有动画，用户可能在动画过程中快速点击了新的照片
            // 这里应该忽略
            if selectedCount == configuration.maxSelectCount {
                return
            }
            
            asset.order = selectedCount
            selectedAssetList.append(asset)
            
            // 到达最大值，就无法再选了
            if selectedCount + 1 == configuration.maxSelectCount {
                collectionView.reloadData()
            }
            else {
                collectionView.reloadItems(at: [getIndexPath(index: asset.index)])
            }
            
        }
        else {
            
            selectedAssetList.remove(at: asset.order)
            asset.order = -1
            
            var changes = [IndexPath]()
            
            changes.append(getIndexPath(index: asset.index))
            
            // 重排顺序
            for i in 0..<selectedAssetList.count {
                let selectedAsset = selectedAssetList[i]
                if i != selectedAsset.order {
                    selectedAsset.order = i
                    changes.append(getIndexPath(index: selectedAsset.index))
                }
            }
            
            // 上个状态是到达上限
            if selectedCount == configuration.maxSelectCount {
                collectionView.reloadData()
            }
            else {
                collectionView.reloadItems(at: changes)
            }
            
        }

    }
    
    private func getIndexPath(index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
    
}

