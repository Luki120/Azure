import UIKit


protocol AlgorithmVCDelegate: AnyObject {
	func algorithmVCDidUpdateAlgorithmLabel(withSelectedRow row: Int)
}

/// Controller that'll show all supported algorithms
final class AlgorithmVC: UITableViewController {

	private let algorithms = ["SHA1", "SHA256", "SHA512"]
	private var selectedRow = 0

	weak var delegate: AlgorithmVCDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
	}

	override init(style: UITableView.Style) {
		super.init(style: .grouped)
		tableView.isScrollEnabled = false
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VanillaCell")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return algorithms.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VanillaCell", for: indexPath)
		selectedRow = IssuerManager.sharedInstance.selectedRow
		delegate?.algorithmVCDidUpdateAlgorithmLabel(withSelectedRow: selectedRow)
		cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none
		cell.backgroundColor = .clear
		cell.textLabel?.font = .systemFont(ofSize: 14)
		cell.textLabel?.text = algorithms[indexPath.row]
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		IssuerManager.sharedInstance.feedSelectedRow(withRow: indexPath.row)
		tableView.reloadData()
	}

}
