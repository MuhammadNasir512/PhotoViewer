import Photos
import UIKit

typealias PHImageManagerResultHandler = (UIImage?, [AnyHashable: Any]?) -> Void
typealias PhotoFetchCompletionHandler = ((UIImage?) -> Void)
typealias SaliencyProcessCompletionHandler = (UIImage?, Error?) -> Void

protocol PhotoCellType where Self: UICollectionViewCell {
    func configure(with viewModel: PhotoCellViewModelType)
}

protocol PhotoCellViewModelType {
    var photoAsset: PHAsset { get }
    var cellIdentifier: String { get }
    func imageForSize(_ size: CGSize, completion: PhotoFetchCompletionHandler?)
}

protocol PHAssetProtocol {
    static func fetchAssets(with options: PHFetchOptions?) -> PHFetchResult<PHAsset>
}
extension PHAsset: PHAssetProtocol {}
