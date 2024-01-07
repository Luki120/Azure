import UIKit


protocol IssuersDataSourceDelegate: AnyObject {
	func didTapCopyPinCode()
	func didTapCopySecret()
	func didTapDeleteAndPresent(alertController: UIAlertController)
	func didAnimateFloatingButton(in scrollView: UIScrollView)
	func shouldAnimateNoIssuersLabel()
	func shouldAnimateNoSearchResultsLabel(forIssuers issuers: [Issuer], isFiltering: Bool)
}

extension IssuersVCView {

	/// Class to handle the data source & delegate for the issuers collection view
	final class IssuersDataSource: NSObject {

		weak var delegate: IssuersDataSourceDelegate?

		private var isFiltered = false
		private var filteredIssuers = [Issuer]()

		private let collectionView: UICollectionView

		/// Designated initializer
		/// - Parameters:
		///		- collectionView: The collection view
		init(collectionView: UICollectionView) {
			self.collectionView = collectionView
		}

		private func setupDataSource(forIssuers issuers: [Issuer], at indexPath: IndexPath, forCell cell: IssuerCell) {
			var issuer = issuers[indexPath.item]
			issuer.index = indexPath.item

			cell.configure(with: issuer)

			KeychainManager.sharedInstance.save(issuer: issuer, forService: issuer.name)
		}

	}

}

// ! UICollectionViewDataSource

extension IssuersVCView.IssuersDataSource: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		delegate?.shouldAnimateNoIssuersLabel()
		delegate?.shouldAnimateNoSearchResultsLabel(forIssuers: filteredIssuers, isFiltering: isFiltered)
		return isFiltered ? filteredIssuers.count : IssuerManager.sharedInstance.issuers.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: IssuerCell.identifier,
			for: indexPath
		) as? IssuerCell else {
			fatalError()
		}

		if isFiltered {
			setupDataSource(forIssuers: filteredIssuers, at: indexPath, forCell: cell)
		}
		else {
			setupDataSource(forIssuers: IssuerManager.sharedInstance.issuers, at: indexPath, forCell: cell)
		}

		return cell
	}	

}

// ! UICollectionViewDelegate

extension IssuersVCView.IssuersDataSource: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			guard let cell = collectionView.cellForItem(at: indexPath) as? IssuerCell else { return UIMenu() }

			let copyCodeAction = UIAction(title: "Copy Code", image: UIImage(systemName: "doc.on.doc")) { _ in
				UIPasteboard.general.string = cell.pinCodeText
				self.delegate?.didTapCopyPinCode()
			}
			let copySecretAction = UIAction(title: "Copy Secret", image: UIImage(systemName: "key.fill")) { _ in
				UIPasteboard.general.string = cell.secret
				self.delegate?.didTapCopySecret()
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

			return UIMenu(title: "", children: [copyCodeAction, copySecretAction, deleteAction])
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		delegate?.didAnimateFloatingButton(in: scrollView)
	}

}

// ! UICollectionViewDragDelegate

extension IssuersVCView.IssuersDataSource: UICollectionViewDragDelegate {

	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		let issuer = IssuerManager.sharedInstance.issuers[indexPath.item]
		let itemProvider = NSItemProvider(object: issuer.name as NSString)
		let dragItem = UIDragItem(itemProvider: itemProvider)
		dragItem.localObject = issuer

		return [dragItem]
	}

	func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
		let parameters = UIDragPreviewParameters()
		let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 374, height: 64), cornerRadius: 14)
		parameters.shadowPath = path
		parameters.visiblePath = path
		parameters.backgroundColor = .clear
		return parameters
	}

}

// ! UICollectionViewDropDelegate

extension IssuersVCView.IssuersDataSource: UICollectionViewDropDelegate {

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

	private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
		guard let item = coordinator.items.first,
			let sourceIndexPath = item.sourceIndexPath,
			let issuer = item.dragItem.localObject as? Issuer else { return }

		collectionView.performBatchUpdates {
			IssuerManager.sharedInstance.issuers.remove(at: sourceIndexPath.item)
			IssuerManager.sharedInstance.issuers.insert(issuer, at: destinationIndexPath.item)

			// Leptos giga chad code, only that I translated it to Swift ™️
			// ⇝ https://github.com/leptos-null/OneTime/blob/88395900c67852bb9e7597c2bdae5a2a150b1844/onetime/ViewControllers/OTPassTableViewController.m#L299
			let start = min(sourceIndexPath.item, destinationIndexPath.item)
			let stop = max(destinationIndexPath.item, sourceIndexPath.item)

			for i in start...stop {
				var issuer = IssuerManager.sharedInstance.issuers[i]
				issuer.index = i

				KeychainManager.sharedInstance.save(issuer: issuer, forService: issuer.name)
			}

			collectionView.deleteItems(at: [sourceIndexPath])
			collectionView.insertItems(at: [destinationIndexPath])
		}

		coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
	}

}

// ! UISearchResultsUpdating

extension IssuersVCView.IssuersDataSource: UISearchResultsUpdating {

	func updateSearchResults(for searchController: UISearchController) {
		guard let searchedString = searchController.searchBar.text else { return }
		updateWithFilteredContent(forString: searchedString)
		collectionView.reloadData()
	}

	func updateWithFilteredContent(forString string: String) {
		let textToSearch = string.trimmingCharacters(in: .whitespacesAndNewlines)
		isFiltered = !textToSearch.isEmpty ? true : false

		filteredIssuers = IssuerManager.sharedInstance.issuers.filter {
			return $0.name.range(of: textToSearch, options: .caseInsensitive) != nil
		}
	}

}
