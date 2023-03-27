import UIKit

/// Class to handle the data source & delegate for the issuers table view
final class IssuersDataSource: NSObject, UITableViewDataSource {

	var issuersVC: IssuersVC!
	var completion: ((IssuerCell?) -> Void)!

	private func setupDataSource(
		forArray array: [Issuer],
		at indexPath: IndexPath,
		forCell cell: IssuerCell
	) {
		var issuer = array[indexPath.row]
		issuer.index = indexPath.row

		cell.setIssuer(withName: issuer.name, secret: issuer.secret, algorithm: issuer.algorithm)

		KeychainManager.sharedInstance.save(issuer: issuer, forService: issuer.name)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		issuersVC.issuersVCView.animateNoIssuersLabel()
		issuersVC.issuersVCView.animateNoSearchResultsLabel(forArray: issuersVC.filteredIssuers, isFiltering: issuersVC.isFiltered)
		return issuersVC.isFiltered ? issuersVC.filteredIssuers.count : IssuerManager.sharedInstance.issuers.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: IssuerCell.identifier,
			for: indexPath
		) as? IssuerCell else {
			return UITableViewCell()
		}
		cell.delegate = issuersVC
		cell.backgroundColor = .clear

		if issuersVC.isFiltered { setupDataSource(forArray: issuersVC.filteredIssuers, at: indexPath, forCell: cell) }
		else { setupDataSource(forArray: IssuerManager.sharedInstance.issuers, at: indexPath, forCell: cell) }

		let image = IssuerManager.sharedInstance.imagesDict[cell.name.lowercased()]
		let resizedImage = image?.resizeImage(image ?? UIImage(), withSize: CGSize(width: 30, height: 30))
		let placeholderImage = UIImage(named: "lock")?.withRenderingMode(.alwaysTemplate)

		cell.issuerImageView.image = image != nil ? resizedImage : placeholderImage
		cell.issuerImageView.tintColor = image != nil ? nil : .kAzureMintTintColor

		completion(cell)

		return cell
	}

}

extension IssuersDataSource: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
			let issuerName = IssuerManager.sharedInstance.issuers[indexPath.row].name
			let message = "You're about to delete the code for the issuer named \(issuerName) ❗❗. Are you sure you want to proceed? You'll have to set the code again if you wished to."
			let alertController = UIAlertController(title: "Azure", message: message, preferredStyle: .alert)

			let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
				IssuerManager.sharedInstance.removeIssuer(at: indexPath)
				self.issuersVC.issuersVCView.issuersTableView.deleteRows(at: [indexPath], with: .fade)
				self.completion(nil)

				completion(true)
			}
			let dismissAction = UIAlertAction(title: "Oops", style: .cancel) { _ in
				completion(true)
			}

			alertController.addAction(confirmAction)
			alertController.addAction(dismissAction)
			self.issuersVC.present(alertController, animated: true)
		}

		action.backgroundColor = .kAzureMintTintColor
 
		return .init(actions: [action])
	}

	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let issuer = IssuerManager.sharedInstance.issuers[sourceIndexPath.row]

		// Leptos giga chad code, only that I translated it to Swift ™️
		// ⇝ https://github.com/leptos-null/OneTime/blob/88395900c67852bb9e7597c2bdae5a2a150b1844/onetime/ViewControllers/OTPassTableViewController.m#L299
		let start = min(sourceIndexPath.row, destinationIndexPath.row)
		let stop = max(destinationIndexPath.row, sourceIndexPath.row)

		IssuerManager.sharedInstance.issuers.remove(at: sourceIndexPath.row)
		IssuerManager.sharedInstance.issuers.insert(issuer, at: destinationIndexPath.row)

		for i in start...stop {
			var issuer = IssuerManager.sharedInstance.issuers[i]
			issuer.index = i

			KeychainManager.sharedInstance.save(issuer: issuer, forService: issuer.name)
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y >= issuersVC.view.safeAreaInsets.bottom + 60 {
			issuersVC.issuersVCView.floatingButtonView.animateView(withAlpha: 0, translateY: 100)
		}
		else { issuersVC.issuersVCView.floatingButtonView.animateView(withAlpha: 1, translateY: 0) }
	}

}
