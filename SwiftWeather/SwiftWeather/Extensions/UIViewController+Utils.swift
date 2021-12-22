//
//  Copyright (C) 2020 Thomas LEGRIS.
//

import UIKit

/// Utility extension for `UIViewController` which provides alert presentation helper.
extension UIViewController {
    /// Show Alert with title, message and one button.
    ///
    /// - Parameters:
    ///   - title: The title of the Alert.
    ///   - message: The body of the Alert.
    func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: Localizable.commonOk,
                                     style: .default,
                                     handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
