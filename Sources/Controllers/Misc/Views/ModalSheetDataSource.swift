import UIKit

/// Class to handle the data source for the modal child view's table view
extension ModalSheetVC {

	final class ModalSheetDataSource: NSObject, UITableViewDataSource {

		private var rowsCount = 3

		private var dataSourceHandler: (NewIssuerOptionsCell, IndexPath) -> Void = { cell, indexPath in
			switch indexPath.row {
				case 0: cell.configure(
					withImage: UIImage(systemName: "qrcode"),
					title: "Scan QR Code",
					selector: #selector(ModalChildView.didTapScanQRCodeButton)
				)
				case 1: cell.configure(
					withImage: UIImage(systemName: "square.and.arrow.up"),
					title: "Import QR Image",
					selector: #selector(ModalChildView.didTapImportQRImageButton)
				)
				case 2: cell.configure(
					withImage: UIImage(systemName: "square.and.pencil"),
					title: "Enter Manually",
					selector: #selector(ModalChildView.didTapEnterManuallyButton)
				)
				default: break
			}
		}

		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return rowsCount
		}

		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			guard let cell = tableView.dequeueReusableCell(
				withIdentifier: NewIssuerOptionsCell.identifier,
				for: indexPath
			) as? NewIssuerOptionsCell else {
				return UITableViewCell()
			}

			dataSourceHandler(cell, indexPath)

			return cell
		}

		// ! Public

		/// Function to setup the backup options data source
		/// - Parameters:
		///		- buttonTarget: The button's target
		///		- selectors: An array of selectors for the buttons
		func setupBackupOptionsDataSource(buttonTarget target: Any?, selectors: [Selector]) {
			rowsCount = 2
			dataSourceHandler = { cell, indexPath in
				switch indexPath.row {
					case 0: cell.configure(
						withImage: UIImage(systemName: "square.and.arrow.down"),
						title: "Load Backup",
						target: target,
						selector: selectors.first!
					)
					case 1: cell.configure(
						withImage: UIImage(systemName: "square.and.arrow.up"),
						title: "Make Backup",
						target: target,
						selector: selectors[1]
					)
					default: break
				}
			}
		}

		/// Function to setup the make backup options data source
		/// - Parameters:
		///		- buttonTarget: The button's target
		///		- selectors: An array of selectors for the buttons
		func setupMakeBackupOptionsDataSource(buttonTarget target: Any?, selectors: [Selector]) {
			rowsCount = 2
			dataSourceHandler = { cell, indexPath in
				switch indexPath.row {
					case 0: cell.configure(
						withImage: UIImage(systemName: "checkmark.circle.fill"),
						title: "Yes",
						target: target,
						selector: selectors.first!
					)
					case 1: cell.configure(
						withImage: UIImage(systemName: "xmark.circle.fill"),
						title: "Later",
						target: target,
						selector: selectors[1]
					)
					default: break
				}
			}
		}

	}

}
