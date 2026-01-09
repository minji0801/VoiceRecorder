//
//  UIButton+Extension.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  버튼 바운스 애니메이션

import UIKit

extension UIButton {
  func animateBounce(completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.1, animations: { self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }) { _ in
      UIView.animate(withDuration: 0.1, animations: { self.transform = .identity }) { _ in
        completion?()
      }
    }
  }
}
