import Photos

extension PHImageManager {
    
    func imageForSize(
        _ size: CGSize,
        photoAsset: PHAsset,
        contentMode: PHImageContentMode = .aspectFill,
        completion: PhotoFetchCompletionHandler?
    ) {
        let resultHandler: PHImageManagerResultHandler = { image, _ in
            completion?(image)
        }
        requestImage(
            for: photoAsset,
               targetSize: size,
               contentMode: contentMode,
               options: nil,
               resultHandler: resultHandler
        )
    }
}

extension CGPoint {
   func scaled(to size: CGSize) -> CGPoint {
       return CGPoint(x: x * size.width, y: y * size.height)
   }
}
