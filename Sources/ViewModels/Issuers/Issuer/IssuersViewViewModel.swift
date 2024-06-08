import Combine
import UIKit


protocol IssuersViewViewModelDelegate: AnyObject {
	func didTapCopyPinCode()
	func didTapCopySecret()
	func didTapDeleteAndPresent(alertController: UIAlertController)
	func didTapAddToSystemAndOpen(url: URL)
	func didAnimateFloatingButton(in scrollView: UIScrollView)
	func didPresent(alertController: UIAlertController)
	func shouldAnimateNoIssuersLabel()
	func shouldAnimateNoSearchResultsLabel(forViewModels viewModels: [IssuerCellViewModel], isFiltering: Bool)
}

extension IssuersView {

	/// View model class for IssuersView
	final class IssuersViewViewModel: NSObject {

		weak var delegate: IssuersViewViewModelDelegate?

		private var saveAction: UIAlertAction!
		private var isFiltering = false
		private var viewModels = [IssuerCellViewModel]()
		private var filteredViewModels = [IssuerCellViewModel]()
		private var subscriptions = Set<AnyCancellable>()

		private let collectionView: UICollectionView

		/// Designated initializer
		/// - Parameters:
		///		- collectionView: The collection view
		init(collectionView: UICollectionView) {
			self.collectionView = collectionView
			super.init()
			updateViewModels()
		}

		private func setupDataSource(
			forViewModels viewModels: [IssuerCellViewModel],
			at indexPath: IndexPath,
			forCell cell: IssuerCell
		) {
			var viewModel = viewModels[indexPath.item]
			viewModel.image = setImage(forIssuer: viewModel.issuer)
			viewModel.issuer.index = indexPath.item

			cell.configure(with: viewModel)

			KeychainManager.sharedInstance.save(issuer: &viewModel.issuer, forService: viewModel.issuer.name, account: viewModel.issuer.account)
		}

		private func setImage(forIssuer issuer: Issuer) -> UIImage? {
			let nullableImage = IssuerManager.sharedInstance.imagesDict[issuer.name.lowercased()]
			let placeholderImage = UIImage(named: "lock")?.withRenderingMode(.alwaysTemplate)

			guard let image = nullableImage != nil ? nullableImage : placeholderImage else { return nil }
			return image
		}

		private func updateViewModels() {
			IssuerManager.sharedInstance.$issuers
				.sink { [weak self] issuers in
					let mappedModels = issuers.map(IssuerCellViewModel.init(_:))
					self?.viewModels = mappedModels
				}
				.store(in: &subscriptions)
		}

		private func makePreviewParameters() -> UIDragPreviewParameters? {
			let parameters = UIDragPreviewParameters()
			let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 374, height: 64), cornerRadius: 14)
			parameters.shadowPath = path
			parameters.visiblePath = path
			parameters.backgroundColor = .clear
			return parameters
		}

	}

}

// ! IssuerCellDelegate

extension IssuersView.IssuersViewViewModel: IssuerCellDelegate {

	func didTapCopyPinCode(in issuerCell: IssuerCell) {
		UIPasteboard.general.string = issuerCell.pinCodeText.replacingOccurrences(of: " ", with: "")
		delegate?.didTapCopyPinCode()
	}

}

// ! UICollectionViewDataSource

extension IssuersView.IssuersViewViewModel: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		delegate?.shouldAnimateNoIssuersLabel()
		delegate?.shouldAnimateNoSearchResultsLabel(forViewModels: filteredViewModels, isFiltering: isFiltering)
		return isFiltering ? filteredViewModels.count : viewModels.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: IssuerCell.identifier,
			for: indexPath
		) as? IssuerCell else {
			fatalError()
		}

		cell.delegate = self

		if isFiltering {
			setupDataSource(forViewModels: filteredViewModels, at: indexPath, forCell: cell)
		}
		else {
			setupDataSource(forViewModels: viewModels, at: indexPath, forCell: cell)
		}

		return cell
	}

}

// ! UICollectionViewDelegate

extension IssuersView.IssuersViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			guard let cell = collectionView.cellForItem(at: indexPath) as? IssuerCell else { return UIMenu() }

			let copySecretAction = UIAction(title: "Copy Secret", image: UIImage(systemName: "key.fill")) { _ in
				UIPasteboard.general.string = cell.secret
				self.delegate?.didTapCopySecret()
			}
			let editAction = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { _ in
				let alertController = UIAlertController(title: "Azure", message: "Enter the new issuer & account name", preferredStyle: .alert)

				var textFields = [UITextField]()

				for index in 0...1 {
					alertController.addTextField { textField in
						switch index {
							case 0: textField.text = self.viewModels[indexPath.item].name
							case 1: textField.text = self.viewModels[indexPath.item].account
							default: break
						}

						textFields.append(textField)

						NotificationCenter.default.addObserver(
							forName: UITextField.textDidChangeNotification,
							object: textField,
							queue: .main
						) { _ in
							self.validateTextFields(textFields)
						}
					}
				}

				self.saveAction = UIAlertAction(title: "Save", style: .default) { _ in
					alertController.textFields?.forEach {
						NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: $0)
					}

					var viewModel = self.viewModels[indexPath.item]

					viewModel.name = alertController.textFields?.first?.text ?? ""
					viewModel.account = alertController.textFields?[1].text ?? ""

					let oldIssuer = IssuerManager.sharedInstance.issuers[indexPath.item]

					var newIssuer: Issuer = .init(
						name: viewModel.name,
						account: viewModel.account,
						secret: viewModel.secret,
						algorithm: viewModel.issuer.algorithm,
						index: indexPath.item,
						creationDate: oldIssuer.creationDate
					)

					viewModel.image = self.setImage(forIssuer: newIssuer)
					cell.configure(with: viewModel)

					UIView.performWithoutAnimation {
						collectionView.reloadData()
					}

					KeychainManager.sharedInstance.save(
						issuer: &newIssuer,
						forService: oldIssuer.name,
						account: oldIssuer.account
					)

					IssuerManager.sharedInstance.updateIssuer(newIssuer, at: indexPath)
				}
				self.saveAction.isEnabled = false

				let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
					alertController.textFields?.forEach {
						NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: $0)
					}
				}

				alertController.addAction(self.saveAction)
				alertController.addAction(cancelAction)

				self.delegate?.didPresent(alertController: alertController)
			}
			let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
				let issuerName = IssuerManager.sharedInstance.issuers[indexPath.item].name
				let message = "You're about to delete the code for the issuer named \(issuerName) ❗❗. Are you sure you want to proceed? You'll need to set 2FA again for this issuer if you wished to."
				let alertController = UIAlertController(title: "Azure", message: message, preferredStyle: .alert)

				let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
					IssuerManager.sharedInstance.removeIssuer(at: indexPath)
					collectionView.deleteItems(at: [indexPath])
				}
				let dismissAction = UIAlertAction(title: "Oops", style: .cancel)

				alertController.addAction(confirmAction)
				alertController.addAction(dismissAction)
				self.delegate?.didTapDeleteAndPresent(alertController: alertController)
			}

			var additionalActions = [UIAction]()

			if #available(iOS 15.0, *) {
				let addToSystemAction = UIAction(title: "Add To System", image: UIImage(systemName: "key")) { _ in
					let issuer = IssuerManager.sharedInstance.issuers[indexPath.item]

					// credits ⇝ https://github.com/leptos-null/OneTime/blob/88395900c67852bb9e7597c2bdae5a2a150b1844/OneTimeKit/Models/OTBag.m#L154
					var urlComponents = URLComponents()
					urlComponents.scheme = "apple-otpauth"
					urlComponents.host = "totp"
					urlComponents.path = "/\(issuer.name):\(issuer.account)"
					urlComponents.queryItems = [
						.init(name: "secret", value: .base32EncodedString(issuer.secret)),
						.init(name: "issuer", value: issuer.name),
						.init(name: "algorithm", value: issuer.algorithm.rawValue.uppercased()),
					]

					guard let url = urlComponents.url else { return }
					self.delegate?.didTapAddToSystemAndOpen(url: url)
				}
				additionalActions.append(addToSystemAction)
			}

			return UIMenu(title: "", children: [
				UIMenu(title: "", options: .displayInline, children: [copySecretAction, editAction, deleteAction]),
				UIMenu(title: "", options: .displayInline, children: additionalActions)
			])
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		delegate?.didAnimateFloatingButton(in: scrollView)
	}

	@objc private func validateTextFields(_ textFields: [UITextField]) {
		saveAction.isEnabled = textFields.allSatisfy { $0.text?.count ?? 0 >= 1 }
	}

}

// ! UICollectionViewDragDelegate

extension IssuersView.IssuersViewViewModel: UICollectionViewDragDelegate {

	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		let viewModel = viewModels[indexPath.item]
		let itemProvider = NSItemProvider(object: viewModel.name as NSString)
		let dragItem = UIDragItem(itemProvider: itemProvider)
		dragItem.localObject = viewModel

		return [dragItem]
	}

	func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
		return makePreviewParameters()
	}

}

// ! UICollectionViewDropDelegate

extension IssuersView.IssuersViewViewModel: UICollectionViewDropDelegate {

	func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
		if collectionView.hasActiveDrag {
			return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
		}
		return UICollectionViewDropProposal(operation: .forbidden)
	}

	func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
		var destinationIndexPath: IndexPath

		if let indexPath = coordinator.destinationIndexPath {
			destinationIndexPath = indexPath
		}
		else {
			let row = collectionView.numberOfItems(inSection: 0)
			destinationIndexPath = IndexPath(item: row - 1, section: 0)
		}

		if coordinator.proposal.operation == .move {
			reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
		}
	}

	func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
		return makePreviewParameters()
	}

	private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
		guard let item = coordinator.items.first,
			let sourceIndexPath = item.sourceIndexPath,
			let viewModel = item.dragItem.localObject as? IssuerCellViewModel else { return }

		collectionView.performBatchUpdates { [weak self] in
			guard let self else { return }

			viewModels.remove(at: sourceIndexPath.item)
			viewModels.insert(viewModel, at: destinationIndexPath.item)

			IssuerManager.sharedInstance.removeIssuer(at: sourceIndexPath.item)
			IssuerManager.sharedInstance.insertIssuer(viewModel.issuer, at: destinationIndexPath.item)

			// Leptos giga chad code, only that I translated it to Swift ™️
			// ⇝ https://github.com/leptos-null/OneTime/blob/88395900c67852bb9e7597c2bdae5a2a150b1844/onetime/ViewControllers/OTPassTableViewController.m#L299
			let start = min(sourceIndexPath.item, destinationIndexPath.item)
			let stop = max(destinationIndexPath.item, sourceIndexPath.item)

			for index in start...stop {
				var viewModel = viewModels[index]
				viewModel.issuer.index = index

				KeychainManager.sharedInstance.save(
					issuer: &viewModel.issuer,
					forService: viewModel.issuer.name,
					account: viewModel.issuer.account
				)
			}

			collectionView.deleteItems(at: [sourceIndexPath])
			collectionView.insertItems(at: [destinationIndexPath])
		}

		coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
	}

}

// ! UISearchResultsUpdating

extension IssuersView.IssuersViewViewModel: UISearchResultsUpdating {

	func updateSearchResults(for searchController: UISearchController) {
		guard let searchedString = searchController.searchBar.text else { return }
		updateWithFilteredContent(forString: searchedString)
		collectionView.reloadData()
	}

	func updateWithFilteredContent(forString string: String) {
		let textToSearch = string.trimmingCharacters(in: .whitespacesAndNewlines)
		isFiltering = !textToSearch.isEmpty ? true : false

		filteredViewModels = viewModels.filter {
			return $0.name.range(of: textToSearch, options: .caseInsensitive) != nil
		}
	}

}
