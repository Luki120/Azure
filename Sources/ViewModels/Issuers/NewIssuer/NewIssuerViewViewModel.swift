import UIKit


protocol NewIssuerViewViewModelDelegate: AnyObject {
	func didFadeInOutToastView(isDuplicateItem: Bool)
	func shouldDismissVC()
}

/// View model class for NewIssuerView
final class NewIssuerViewViewModel: NSObject {

	private var name = ""
	private var account = ""
	private var secret = ""

	weak var delegate: NewIssuerViewViewModelDelegate?

	// ! UITableViewDiffableDataSource

	private enum CellType: Hashable {
		case issuer(viewModel: NewIssuerFormCellViewModel)
		case account(viewModel: NewIssuerFormCellViewModel)
		case secret(viewModel: NewIssuerFormCellViewModel)
		case algorithm(viewModel: NewIssuerAlgorithmCellViewModel)
	}

	private var cells = [CellType]()

	private let issuerViewModel = NewIssuerFormCellViewModel(tag: 0, placeholder: "Enter name", returnKeyType: .next)
	private let accountViewModel = NewIssuerFormCellViewModel(tag: 1, placeholder: "E-mail or username", returnKeyType: .next)
	private let secretViewModel = NewIssuerFormCellViewModel(tag: 2, placeholder: "Enter secret", returnKeyType: .default)
	private let algorithmViewModel = NewIssuerAlgorithmCellViewModel(
		algorithmText: "Algorithm",
		items: ["SHA1", "SHA256", "SHA512"],
		selectedSegmentIndex: IssuerManager.sharedInstance.selectedIndex
	)

	@frozen private enum Section: String {
		case issuer = "Issuer"
		case account = "Account"
		case secret = "Secret"
		case algorithm = "Type"

		var headerTitle: String {
			switch self {
				case .issuer, .account, .secret, .algorithm: return rawValue
			}
		}
	}

	private typealias DataSource = UITableViewDiffableDataSource<Section, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellType>

	private var dataSource: DataSource!

	override init() {
		super.init()

		cells = [
			.issuer(viewModel: issuerViewModel),
			.account(viewModel: accountViewModel),
			.secret(viewModel: secretViewModel),
			.algorithm(viewModel: algorithmViewModel)
		]

		NotificationCenter.default.addObserver(self, selector: #selector(shouldSaveData), name: .shouldSaveDataNotification, object: nil)
	}

	// ! NotificationCenter

	@objc private func shouldSaveData() {
		if name.count == 0 || account.count == 0 || secret.count == 0 {
			NotificationCenter.default.post(name: .shouldResignResponderNotification, object: nil)
			delegate?.didFadeInOutToastView(isDuplicateItem: false)
			return
		}

		IssuerManager.sharedInstance.createIssuer(
			withName: name,
			account: account,
			secret: .base32DecodedString(secret)
		) { isDuplicateItem, issuer in

			guard !isDuplicateItem else {
				NotificationCenter.default.post(name: .shouldResignResponderNotification, object: nil)
				delegate?.didFadeInOutToastView(isDuplicateItem: true)
				return
			}

			IssuerManager.sharedInstance.appendIssuer(issuer)
			delegate?.shouldDismissVC()
		}
	}

}

// ! UITableView

extension NewIssuerViewViewModel: UITableViewDelegate {

	final private class WorkingDataSource: DataSource {
		override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
			let section = self.snapshot().sectionIdentifiers[section]
			return section.headerTitle
		}
	}

	/// Function to setup the table view's diffable data source
	/// - Parameters:
	///		- tableView: The table view
	func setupTableView(_ tableView: UITableView) {
		dataSource = WorkingDataSource(tableView: tableView) { [weak self] tableView, indexPath, _ in
			guard let self else { fatalError() }

			switch cells[indexPath.section] {
				case .issuer(let viewModel):
					let cell: NewIssuerFormCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: viewModel)
					cell.completion = { [weak self] text in
						self?.name = text
					}
					return cell

				case .account(let viewModel):
					let cell: NewIssuerFormCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: viewModel)
					cell.completion = { [weak self] text in
						self?.account = text
					}
					return cell

				case .secret(let viewModel):
					let cell: NewIssuerFormCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: viewModel)
					cell.completion = { [weak self] text in
						self?.secret = text
					}
					return cell

				case .algorithm(let viewModel):
					let cell: NewIssuerAlgorithmCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: viewModel)
					cell.delegate = self
					return cell
			}
		}
		applySnapshot()
	}

	private func applySnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.issuer, .account, .secret, .algorithm])
		snapshot.appendItems(cells.filter { $0 == .issuer(viewModel: issuerViewModel) }, toSection: .issuer)
		snapshot.appendItems(cells.filter { $0 == .account(viewModel: accountViewModel) }, toSection: .account)
		snapshot.appendItems(cells.filter { $0 == .secret(viewModel: secretViewModel) }, toSection: .secret)
		snapshot.appendItems(cells.filter { $0 == .algorithm(viewModel: algorithmViewModel) }, toSection: .algorithm)
		dataSource.apply(snapshot)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}

}

// ! NewIssuerAlgorithmCellDelegate

extension NewIssuerViewViewModel: NewIssuerAlgorithmCellDelegate {

	func didChangeSelectedIndex(_ index: Int) {
		IssuerManager.sharedInstance.setSelectedIndex(index)
	}

}
