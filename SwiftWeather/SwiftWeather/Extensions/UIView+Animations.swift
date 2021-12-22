//
//  Copyright (C) 2020 Thomas LEGRIS.
//

import UIKit

/// Animation extension for `UIView`.
extension UIView {
    /// Start rotation animation on a UIView.
    ///
    /// - Parameters:
    ///     - repeatCount: number of times the animation will repeat
    func startRotate(repeatCount: Float = Float.greatestFiniteMagnitude) {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = repeatCount
        self.layer.add(rotation, forKey: "rotationAnimation")
    }

    /// Stop rotation animation on a UIView.
    func stopRotate() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
