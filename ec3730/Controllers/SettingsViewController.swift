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

        view.backgroundColor = UIColor.groupTableViewBackground
        // Do any additional setup after loading the view, typically from a nib.
        title = "Settings"
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 3
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: do this automagically
        // https://stackoverflow.com/questions/36378001/is-it-possible-to-count-pictures-in-asset-catalog-with-particular-prefix
        switch section {
        case 0: // Browser
            return 1
        case 1: // Contact/Rate
            if MFMailComposeViewController.canSendMail() {
                return 2
            }
            return 1
        case 2: // Legal
            return 2
        default:
            return 0
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Browser"
        case 2:
            return "Legal"
        default:
            return nil
        }
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "enabled1")

        cell.accessoryType = .disclosureIndicator

        switch indexPath.section {
        case 0:
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

        case 1:
            var modifier = -1
            if MFMailComposeViewController.canSendMail() {
                modifier = 0
            }
            switch indexPath.row {
            case 0 + modifier:
                cell.textLabel?.text = "Contact"
                cell.imageView?.image = UIImage(named: "at")
            case 1 + modifier:
                cell.textLabel?.text = "Rate"
                cell.imageView?.image = UIImage(named: "star")
            default:
                break
            }
        case 2:
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
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

            if let popoverController = browserSheet.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = UIPopoverArrowDirection()
            }

            for (index, action) in browserSheet.actions.enumerated() {
                if UserDefaults.standard.integer(forKey: "open_browser") == index {
                    action.setValue("true", forKey: "checked")
                } else {
                    action.setValue("false", forKey: "checked")
                }
            }
            browserSheet.addActionSheetForiPad()
            present(browserSheet, animated: true) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 1:
            var modifier = -1
            if MFMailComposeViewController.canSendMail() {
                modifier = 0
            }
            switch indexPath.row {
            case 0 + modifier:
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                composeVC.setToRecipients(["zac+netutils@gorak.us"])
                // swiftlint:disable:next force_cast
                composeVC.setSubject((Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String) + " v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))

                // Present the view controller modally.
                composeVC.addActionSheetForiPad()
                present(composeVC, animated: true, completion: nil)

            case 1 + modifier:
                let rateBlock = {
                    UIApplication.shared.open(URL(string: "https://itunes.apple.com/gb/app/id1434360325?action=write-review&mt=8")!, options: [:], completionHandler: { _ in
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                }

                // Only rate right away 45% of the time - otherwise filter users
                let rand = arc4random_uniform(100)

                if rand < 45 { // 45%
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
                        secondAlert.addActionSheetForiPad()
                        self.present(secondAlert, animated: true, completion: nil)
                    })
                    alert.addAction(no)
                    alert.addActionSheetForiPad()
                    present(alert, animated: true, completion: {
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                }
            default:
                break
            }
        case 2:
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