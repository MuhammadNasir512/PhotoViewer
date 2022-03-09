import Foundation
import Photos

protocol PermissionHandlerType {
    func verifyPhotoLibraryPermission(_ completion: ((Bool) -> Void)?)
}

final class PermissionHandler: PermissionHandlerType {
    func verifyPhotoLibraryPermission(_ completion: ((Bool) -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite)
        guard status != .authorized else {
            completion?(true)
            return
        }
        PHPhotoLibrary.requestAuthorization { status in
            completion?(status == .authorized)
        }
    }
}
