import UIKit


protocol NewIssuerOptionsViewViewModelDelegate: AnyObject {
	func didTapScanQRCodeCell()
	func didTapImportQRImageCell()
	func didTapEnterManuallyCell()
	func didTapLoadBackupCell()
	func didTapMakeBackupCell()
	func didTapViewInFilesOrFilzaCell()
	func didTapDismissCell()
}

extension NewIssuerOptionsView {

	/// View model class for NewIssuerOptionsView
	final class NewIssuerOptionsViewViewModel: NSObject {

		private let newIssuerOptionsViewModels: [NewIssuerOptionsCellViewModel] = [
			.init(image: UIImage(systemName: "qrcode"), text: "Scan QR Code"),
			.init(image: UIImage(systemName: "square.and.arrow.up"), text: "Import QR Image"),
			.init(image: UIImage(systemName: "square.and.pencil"), text: "Enter Manually")
		]

		private let backupOptionsViewModels: [NewIssuerOptionsCellViewModel] = [
			.init(image: UIImage(systemName: "square.and.arrow.down"), text: "Load Backup"),
			.init(image: UIImage(systemName: "square.and.arrow.up"), text: "Make Backup")
		]

		private let makeBackupOptionsViewModels: [NewIssuerOptionsCellViewModel] = [
			.init(image: UIImage(systemName: "checkmark.circle.fill"), text: "Yes"),
			.init(image: UIImage(systemName: "xmark.circle.fill"), text: "No")
		]

		private var isBackupOptions = false
		private var rowsCount = 3

		private lazy var dataSourceHandler: (NewIssuerOptionsCell, IndexPath) -> Void = { cell, indexPath in
			cell.configure(with: self.newIssuerOptionsViewModels[indexPath.row])
		}

		weak var delegate: NewIssuerOptionsViewViewModelDelegate?

	}

}

// ! UITableViewDataSource

extension NewIssuerOptionsView.NewIssuerOptionsViewViewModel: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rowsCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: NewIssuerOptionsCell = tableView.dequeueReusableCell(for: indexPath)
		dataSourceHandler(cell, indexPath)
		return cell
	}

}

// ! UITableViewDelegate

extension NewIssuerOptionsView.NewIssuerOptionsViewViewModel: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		if rowsCount == 3 {
			switch indexPath.row {
				case 0: delegate?.didTapScanQRCodeCell()
				case 1: delegate?.didTapImportQRImageCell()
				case 2: delegate?.didTapEnterManuallyCell()
				default: break
			}
		}
		else {
			if isBackupOptions {
				switch indexPath.row {
					case 0: delegate?.didTapLoadBackupCell()
					case 1: delegate?.didTapMakeBackupCell()
					default: break
				}
			}
			else {
				switch indexPath.row {
					case 0: delegate?.didTapViewInFilesOrFilzaCell()
					case 1: delegate?.didTapDismissCell()
					default: break
				}
			}
		}
	}

}

extension NewIssuerOptionsView.NewIssuerOptionsViewViewModel {

	// ! Public

	/// Function to setup the backup options data source
	func setupBackupOptionsDataSource() {
		isBackupOptions = true
		rowsCount = 2

		dataSourceHandler = { cell, indexPath in
			cell.configure(with: self.backupOptionsViewModels[indexPath.row])
		}
	}

	/// Function to setup the make backup options data source
	func setupMakeBackupOptionsDataSource() {
		isBackupOptions = false
		rowsCount = 2

		dataSourceHandler = { cell, indexPath in
			cell.configure(with: self.makeBackupOptionsViewModels[indexPath.row])
		}
	}

}
