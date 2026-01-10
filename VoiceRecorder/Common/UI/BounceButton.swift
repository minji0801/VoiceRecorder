//
//  BounceButton.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  탭할 때 바운스 애니메이션이 있는 버튼

import UIKit

final class BounceButton: UIButton {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    addTarget(self, action: #selector(touchDown), for: .touchUpInside)
  }
  
  @objc private func touchDown() {
    let duration = 0.1
    let scale = 0.9
    
    UIView.animate(withDuration: duration) { [weak self] in
      guard let self = self else { return }
      self.transform = CGAffineTransform(scaleX: scale, y: scale)
    } completion: { _ in
      UIView.animate(withDuration: duration) { [weak self] in
        guard let self = self else { return }
        self.transform = .identity
      }
    }
  }
}
