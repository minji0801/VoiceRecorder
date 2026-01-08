//
//  RecordingVC.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import UIKit
import SnapKit

final class RecordingVC: UIViewController {
  
  // 타임 라벨
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 20, weight: .bold)
    label.text = "00:00"
    label.textColor = .white
    return label
  }()
  
  // 레코딩 버튼
  private lazy var recordButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .systemRed
    button.layer.cornerRadius = 40
    button.layer.borderWidth = 4
    button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
  }
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    view.addSubview(timeLabel)
    view.addSubview(recordButton)
  }
  
  private func setupConstraints() {
    timeLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    recordButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(timeLabel.snp.bottom).offset(20)
      make.size.equalTo(80)
    }
  }
  
  @objc private func recordButtonTapped() {
    print("오디오 레코드 시작")
    recordButton.animateBounce()
  }
}

extension UIButton {
  func animateBounce(completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.1, animations: { self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }) { _ in
      UIView.animate(withDuration: 0.1, animations: { self.transform = .identity }) { _ in
        completion?()
      }
    }
  }
}
