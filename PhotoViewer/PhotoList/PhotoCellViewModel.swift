import Photos

final class PhotoCellViewModel: PhotoCellViewModelType {
    let photoAsset: PHAsset
    let cellIdentifier = "PhotoCell"
    private let imageManager: PHImageManager
    
    init(photoAsset: PHAsset, imageManager: PHImageManager = PHImageManager.default()) {
        self.imageManager = imageManager
        self.photoAsset = photoAsset
    }
    
    func imageForSize(_ size: CGSize, completion: PhotoFetchCompletionHandler?) {
        imageManager.imageForSize(size, photoAsset: photoAsset, completion: completion)
    }
}
