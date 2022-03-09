import XCTest
import Photos
@testable import PhotoViewer

final class PhotoListViewModelTests: XCTestCase {

    func testLoadOfAssets() {
        let permissionHandler = PermissionHandlerMock()
        let sut = PhotoListViewModel(permissionHandler: permissionHandler)
        
        let exp = expectation(description: "exp1")
        permissionHandler.expectation = exp
        
        sut.loadImages(PHAssetMock.self)
        XCTAssertEqual(permissionHandler.verifyPermissionCallCount, 1)
        
        wait(for: [exp], timeout: 2)
        XCTAssertEqual(sut.photoCellItems.count, 0)
    }
}

final class PermissionHandlerMock: PermissionHandlerType {
    var verifyPermissionCallCount = 0
    var expectation = XCTestExpectation()
    
    func verifyPhotoLibraryPermission(_ completion: @escaping (Bool) -> Void) {
        verifyPermissionCallCount += 1
        completion(true)
        expectation.fulfill()
    }
}

final class PHAssetMock: PHAssetProtocol {
    class func fetchAssets(with options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        return PHFetchResult<PHAsset>()
    }
}
