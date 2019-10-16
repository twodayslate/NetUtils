//
//  ViewController.swift
//  acft
//
//  Created by Zachary Gorak on 10/15/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import MessageUI
import SafariServices
import UIKit

class SettingsNavigationController: UINavigationController {
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName _: String?, bundle _: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [SettingsTableViewController(style: .grouped)]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGroupedBackground
        // Do any additional setup after loading the view, typically from a nib.
        title = "Settings"
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 5
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: do this automagically
        // https://stackoverflow.com/questions/36378001/is-it-possible-to-count-pictures-in-asset-catalog-with-particular-prefix
        switch section {
        case 0: // Data feeds
            return 1
        case 1: // Appearance
            return 1
        case 2: // Browser
            return 1
        case 3: // Contact/Rate
            return 3
        case 4: // Legal
            return 2
        default:
            return 0
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Appearance"
        case 2:
            return "Browser"
        case 4:
            return "Legal"
        default:
            return nil
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "enabled1")

        cell.accessoryType = .disclosureIndicator

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Data Feeds"
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Theme"
                switch UserDefaults.standard.integer(forKey: "theme") {
                case 1:
                    cell.detailTextLabel?.text = "Light"
                case 2:
                    cell.detailTextLabel?.text = "Dark"
                default:
                    cell.detailTextLabel?.text = "System"
                }
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Open Links in"
                switch UserDefaults.standard.integer(forKey: "open_browser") {
                case 1:
                    cell.detailTextLabel?.text = "Safari"
                default:
                    cell.detailTextLabel?.text = "In-App Safari"
                }
            default:
                break
            }

        case 3:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Contact"
                cell.imageView?.image = UIImage(named: "at")
            case 1:
                cell.textLabel?.text = "Twitter"
                cell.imageView?.image = UIImage(named: "twitter")
            case 2:
                cell.textLabel?.text = "Rate"
                cell.imageView?.image = UIImage(named: "star")
            default:
                break
            }
        case 4:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Privacy Policy"
            case 1:
                cell.textLabel?.text = "Terms of Use"
            default:
                break
            }
        default:
            break
        }
        return cell
    }

    let browserSheet = UIAlertController(title: "Browser", message: nil, preferredStyle: .actionSheet)
    let themeSheet = UIAlertController(title: "Theme", message: nil, preferredStyle: .actionSheet)

    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let feed = DataFeedsTableViewController(style: .grouped)
            tableView.deselectRow(at: indexPath, animated: true)
            navigationController?.pushViewController(feed, animated: true)
        case 1:
            if themeSheet.actions.count == 0 {
                let inappSafariAction = UIAlertAction(title: "System", style: .default, handler: { _ in
                    print("Auto")
                    UserDefaults.standard.set(0, forKey: "theme")
                    UserDefaults.standard.synchronize()
                    let cell = self.tableView.cellForRow(at: indexPath)
                    cell?.detailTextLabel?.text = "System"
                })
                themeSheet.addAction(inappSafariAction)
                if #available(iOS 13.0, *) {
                    let safariAction = UIAlertAction(title: "Light", style: .default, handler: { _ in
                        print("Auto")
                        UserDefaults.standard.set(1, forKey: "theme")
                        UserDefaults.standard.synchronize()
                        let cell = self.tableView.cellForRow(at: indexPath)
                        cell?.detailTextLabel?.text = "Light"
                    })
                    themeSheet.addAction(safariAction)
                    let darkAction = UIAlertAction(title: "Dark", style: .default, handler: { _ in
                        print("Dark")
                        UserDefaults.standard.set(2, forKey: "theme")
                        UserDefaults.standard.synchronize()
                        let cell = self.tableView.cellForRow(at: indexPath)
                        cell?.detailTextLabel?.text = "Dark"
                    })
                    themeSheet.addAction(darkAction)
                }
                themeSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }

            for (index, action) in themeSheet.actions.enumerated() {
                if UserDefaults.standard.integer(forKey: "theme") == index {
                    action.setValue("true", forKey: "checked")
                } else {
                    action.setValue("false", forKey: "checked")
                }
            }
            // swiftlint:disable:next line_length
            themeSheet.addActionSheetForiPad(sourceView: tableView.cellForRow(at: indexPath), sourceRect: tableView.cellForRow(at: indexPath)?.detailTextLabel?.frame, permittedArrowDirections: UIPopoverArrowDirection.any)
            present(themeSheet, animated: true) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 2:
            if browserSheet.actions.count == 0 {
                let inappSafariAction = UIAlertAction(title: "In-App Safari", style: .default, handler: { _ in
                    print("In-app Safari")
                    UserDefaults.standard.set(0, forKey: "open_browser")
                    UserDefaults.standard.synchronize()
                    let cell = self.tableView.cellForRow(at: indexPath)
                    cell?.detailTextLabel?.text = "In-App Safari"
                })
                browserSheet.addAction(inappSafariAction)
                let safariAction = UIAlertAction(title: "Safari", style: .default, handler: { _ in
                    print("Safari")
                    UserDefaults.standard.set(1, forKey: "open_browser")
                    UserDefaults.standard.synchronize()
                    let cell = self.tableView.cellForRow(at: indexPath)
                    cell?.detailTextLabel?.text = "Safari"
                })
                browserSheet.addAction(safariAction)
                browserSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }

            for (index, action) in browserSheet.actions.enumerated() {
                if UserDefaults.standard.integer(forKey: "open_browser") == index {
                    action.setValue("true", forKey: "checked")
                } else {
                    action.setValue("false", forKey: "checked")
                }
            }
            // swiftlint:disable:next line_length
            browserSheet.addActionSheetForiPad(sourceView: tableView.cellForRow(at: indexPath), sourceRect: tableView.cellForRow(at: indexPath)?.detailTextLabel?.frame, permittedArrowDirections: UIPopoverArrowDirection.any)
            present(browserSheet, animated: true) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 3:
            switch indexPath.row {
            case 0:
                // swiftlint:disable:next force_cast
                var subject = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String) + " v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = self
                    composeVC.setToRecipients(["zac+netutils@gorak.us"])
                    composeVC.setSubject(subject)

                    // Present the view controller modally.
                    composeVC.addActionSheetForiPad(sourceView: view)
                    present(composeVC, animated: true, completion: {
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                } else {
                    subject = subject.replacingOccurrences(of: " ", with: "%20")
                    let url = URL(string: "mailto:zac+netutils@gorak.us&subject=\(subject)")!

                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                            tableView.deselectRow(at: indexPath, animated: true)
                        })
                    } else {
                        showError("Email Me", message: "zac+netutils@gorak.us")
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            case 1:
                let twitter = URL(string: "twitter://user?screen_name=twodayslate")!
                if UIApplication.shared.canOpenURL(twitter) {
                    UIApplication.shared.open(twitter, options: [:], completionHandler: { success in
                        if !success {
                            self.open(URL(string: "https://twitter.com/twodayslate")!, title: "Twitter") { _ in
                                tableView.deselectRow(at: indexPath, animated: true)
                            }
                        }
                        DispatchQueue.main.async {
                            tableView.deselectRow(at: indexPath, animated: true)
                        }
                    })
                } else {
                    open(URL(string: "https://twitter.com/twodayslate")!, title: "Twitter") { _ in
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            case 2:
                let rateBlock = {
                    UIApplication.shared.open(URL(string: "https://itunes.apple.com/gb/app/id1434360325?action=write-review&mt=8")!, options: [:], completionHandler: { _ in
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                }

                // Only rate right away 25% of the time - otherwise filter users
                let rand = arc4random_uniform(100)

                if rand < 25 { // 25% can rate directly
                    rateBlock()
                } else {
                    let alert = UIAlertController(title: "Rate", message: "Do you love this app?", preferredStyle: .alert)
                    let yes = UIAlertAction(title: "Yes", style: .default, handler: {
                        _ in
                        rateBlock()
                    })
                    alert.addAction(yes)
                    let no = UIAlertAction(title: "No", style: .destructive, handler: {
                        _ in

                        let secondAlert = UIAlertController(title: "Thank you", message: "Thanks for the feedback! Please email us your specific feedback!", preferredStyle: .alert)
                        let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        secondAlert.addAction(okay)
                        secondAlert.addActionSheetForiPad(sourceView: self.view)
                        self.present(secondAlert, animated: true, completion: nil)
                    })
                    alert.addAction(no)
                    alert.addActionSheetForiPad(sourceView: view)
                    present(alert, animated: true, completion: {
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                }
            default:
                break
            }
        case 4:
            switch indexPath.row {
            case 0:
                open(URL(string: "https://zac.gorak.us/ios/privacy.html")!, title: "Privacy Policy") { _ in
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            case 1:
                open(URL(string: "https://zac.gorak.us/ios/terms.html")!, title: "Privacy Policy") { _ in
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            default:
                break
            }
        default:
            break
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
