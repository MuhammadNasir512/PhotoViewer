import Foundation
import UIKit
import Combine
import Photos

final class PhotoListViewModel {
    @Published var photoCellItems = [PhotoCellViewModelType]()
    private var permissionHandler: PermissionHandlerType

    init(permissionHandler: PermissionHandlerType = PermissionHandler()) {
        self.permissionHandler = permissionHandler
    }

    func loadImages(_ phAsset: PHAssetProtocol.Type = PHAsset.self) {
        permissionHandler.verifyPhotoLibraryPermission { [weak self] isPermitted in
            guard isPermitted else {
                print("Photo library access required")
                return
            }
            guard let self = self else { return }
            let assets = phAsset.fetchAssets (with: self.fetchOptions())
            var photoCellItems = [PhotoCellViewModelType]()
            assets.enumerateObjects { asset, index, stop in
                let model = PhotoCellViewModel(photoAsset: asset)
                photoCellItems.append(model)
            }
            self.photoCellItems = photoCellItems
        }
    }

    private func fetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchOptions.fetchLimit = Constant.imagesFetchLimit
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        return fetchOptions
    }

    private func requestOptions() -> PHImageRequestOptions {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }

    func detailsViewController(forItemAt index: Int) -> UIViewController {
        let photoAsset = photoCellItems[index].photoAsset
        let detailsViewModel = PhotoDetailsViewModel(photoAsset: photoAsset)
        let detailsVC = PhotoDetailsViewController(viewModel: detailsViewModel)
        return detailsVC
    }
}

extension PhotoListViewModel {
    private enum Constant {
        static let imagesFetchLimit = 1000
    }
}
