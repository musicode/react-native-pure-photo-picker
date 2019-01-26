
import UIKit

public class AlbumList: UIView {
    
    public var onAlbumClick: ((Album) -> Void)?
    
    public var albumList = [Album]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var configuration: PhotoPickerConfiguration!
    
    private let cellIdentifier = "cell"
    
    private lazy var cellPosterPixelSize: CGSize = {
        let size = CGSize(width: configuration.albumPosterWidth, height: configuration.albumPosterHeight)
        return PhotoPickerManager.shared.getPixelSize(size: size)
    }()
    
    private lazy var tableView: UITableView = {
        
        let view = UITableView()
        
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        
        view.delegate = self
        view.dataSource = self
        
        view.estimatedRowHeight = 100
        view.rowHeight = UITableView.automaticDimension
        
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = configuration.albumBackgroundColorNormal
        view.separatorStyle = .none
        
        view.register(AlbumCell.self, forCellReuseIdentifier: cellIdentifier)
        
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
    }
    
}

//
// MARK: - 数据源
//

extension AlbumList: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AlbumCell
        let index = indexPath.row
        
        cell.configuration = configuration
        cell.bind(index: index, album: albumList[ index ], posterSize: cellPosterPixelSize)
        
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onAlbumClick?(albumList[indexPath.row])
    }
    
}

