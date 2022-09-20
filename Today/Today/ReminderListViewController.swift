import UIKit

class ReminderListViewController: UICollectionViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String> // 데이터와 연결하기 위한 DataSource 생성
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String> // 데이터를 가져오기 위한 Snapshot 생성
    
    var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 레이아웃 설정
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        // Cell Registration 생성
        let cellRegistration = UICollectionView.CellRegistration { (cell: UICollectionViewListCell, indexPath: IndexPath, itemIdentifier: String) in
            let reminder = Reminder.sampleData[indexPath.item]
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = reminder.title
            cell.contentConfiguration = contentConfiguration // contentConfiguration — Describes the cell’s labels, images, buttons, and more
            // backgroundConfiguration -> Describes the cell’s background color, gradient, image, and other visual attributes
            // configurationState — Describes the cell’s style when the user selects, highlights, drags, or otherwise interacts with it
        }
        
        // dataSource 설정
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: String) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        // snapshot 설정
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // only one section in this list
        snapshot.appendItems(Reminder.sampleData.map { $0.title })
        dataSource.apply(snapshot)
        
        collectionView.dataSource = dataSource
    }

    // listLayout 생성 메소드
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = true
        listConfiguration.backgroundColor = .clear
        
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

}

