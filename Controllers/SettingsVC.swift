import UIKit


@objc public class SettingsVC: UIViewController {

	private let theSwitch: UISwitch = {
		let theSwitch = UISwitch()
		theSwitch.onTintColor = .systemTeal
		return theSwitch
	}()

	private let settingsTableView: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()

	public init() {
		super.init(nibName: nil, bundle: nil)
		setupUI()
		settingsTableView.dataSource = self
		settingsTableView.delegate = self
		settingsTableView.tableFooterView = UIView()
		theSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
		theSwitch.setOn(UserDefaults.standard.bool(forKey: "useBiometrics"), animated: false)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		layoutUI()
	}

	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		settingsTableView.isScrollEnabled = true
	}

	public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
	}

	private func setupUI() {

		view.addSubview(settingsTableView)

	}

	private func layoutUI() {

		settingsTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

	}

	@objc private func switchChanged() {

		UserDefaults.standard.set(theSwitch.isOn, forKey: "useBiometrics")

	}

}


extension SettingsVC: UITableViewDataSource, UITableViewDelegate {

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.backgroundColor = .clear

		switch indexPath.row {

			case 0:
				cell.accessoryView = theSwitch
				cell.textLabel?.text = "Use Biometrics"

			case 1:
				cell.textLabel?.text = "Purge Data"
				cell.textLabel?.textColor = .systemRed

			default: break

		}

		return cell

	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		if indexPath.row == 1 {

			let alertController = UIAlertController(
				title: "Azure",
				message: "YO DUDE!! Hold up right there. You’re about to purge ALL of your 2FA codes and your data, ARE YOU ABSOLUTELY SURE? ❗️❗️Don’t be a dumbass, you’ll regret it later. I warned you 😈.",
				preferredStyle: .alert
			)

			alertController.addAction(UIAlertAction(title: "I'm sure", style: .destructive, handler: { _ in

				NotificationCenter.default.post(name: Notification.Name("purgeDataDone"), object: nil)
				self.dismiss(animated: true, completion: nil)

			}))

			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

			present(alertController, animated: true, completion: nil)

		}

	}

}
