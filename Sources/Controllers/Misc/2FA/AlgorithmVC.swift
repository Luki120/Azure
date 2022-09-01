import UIKit


protocol AlgorithmVCDelegate: AnyObject {
	func algorithmVCDidUpdateAlgorithmLabel(withSelectedRow row: Int)
}

final class AlgorithmVC: UITableViewController {

	private let algorithmTableArray = ["SHA1", "SHA256", "SHA512"]
	private var selectedRow = 0

	weak var delegate: AlgorithmVCDelegate?

	init() {
		super.init(style: .grouped)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VanillaCell")
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return algorithmTableArray.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VanillaCell", for: indexPath)
		selectedRow = TOTPManager.sharedInstance.selectedRow
		delegate?.algorithmVCDidUpdateAlgorithmLabel(withSelectedRow: selectedRow)
		cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none
		cell.backgroundColor = .clear
		cell.textLabel?.font = .systemFont(ofSize: 14)
		cell.textLabel?.text = algorithmTableArray[indexPath.row]
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		TOTPManager.sharedInstance.feedSelectedRow(withRow: indexPath.row)
		tableView.reloadData()
	}

}
