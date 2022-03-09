import UIKit
import Vision

final class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    let viewModel: PhotoDetailsViewModel

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(viewModel: PhotoDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showImageInImageView()
    }

    private func showImageInImageView() {
        viewModel.imageForSize(view.bounds.size) { [weak self] image in
            guard let image = image, let self = self else { return }
            self.onImageLoaded(image: image)
        }
    }

    private func onImageLoaded(image: UIImage) {
        viewModel.processSaliency(in: image) { [weak self] resultImage, error in
            guard let self = self, let resultImage = resultImage else { return }
            self.photoImageView.image = resultImage
        }
    }
}
