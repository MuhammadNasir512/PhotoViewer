import UIKit

final class PhotoCell: UICollectionViewCell, PhotoCellType {

    @IBOutlet weak var photoImageView: UIImageView!

    func configure(with viewModel: PhotoCellViewModelType) {
        viewModel.imageForSize(bounds.size) { [weak self] image in
            self?.photoImageView.image = image
        }
    }
}
