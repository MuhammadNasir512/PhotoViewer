import UIKit
import Combine

final class PhotoListViewController: UIViewController {

    private enum Constant {
        static let photosGridColumns: CGFloat = 4
        static let photoItemsPadding: CGFloat = 5
    }

    @IBOutlet weak var collectionView: UICollectionView!
    private var cancellables = [AnyCancellable]()
    private let viewModel: PhotoListViewModel

    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        viewModel = PhotoListViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupSubscriptions()
        viewModel.loadImages()
    }

    private func setupViews() {
        let spacing = Constant.photoItemsPadding
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView.collectionViewLayout = layout
    }

    private func setupSubscriptions() {
        viewModel.$photoCellItems.receive(on: DispatchQueue.main).sink { [weak self] photoCellModels in
            self?.collectionView.reloadData()
        }
        .store(in: &cancellables)
    }
}

extension PhotoListViewController: UICollectionViewDataSource {

    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photoCellItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCellViewModel = viewModel.photoCellItems[indexPath.item]
        let cellId = photoCellViewModel.cellIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PhotoCellType else {
            return UICollectionViewCell()
        }
        cell.configure(with: photoCellViewModel)
        return cell
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let columns = Constant.photosGridColumns
        let totalSpacing = (columns - 1) * Constant.photoItemsPadding
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width)
    }
}

extension PhotoListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = viewModel.detailsViewController(forItemAt: indexPath.item)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
