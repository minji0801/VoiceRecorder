//
//  PermissionRequestView.swift
//  VoiceRecorder
//
//  Created by 김민지 on 1/10/26.
//

import UIKit
import SnapKit

final class PremissionRequstView: UIView {
  
  private let contentView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 16
    stackView.alignment = .fill
    stackView.distribution = .fill
    return stackView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "마이크 접근 권한을 허용해주세요."
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .white
    return label
  }()
  
  private lazy var moveButton: BounceButton = {
    let button = BounceButton()
    button.setTitle("설정으로 이동", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
    button.tintColor = .white
    button.backgroundColor = .customPurple
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  private func setupUI() {
    backgroundColor = .customNavy
    isOpaque = false
    layer.cornerRadius = 12
    clipsToBounds = true
    
    contentView.addArrangedSubview(titleLabel)
    contentView.addArrangedSubview(moveButton)
    
    addSubview(contentView)
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(14)
    }
    
    moveButton.snp.makeConstraints { make in
      make.width.equalTo(80)
    }
  }
  
  @objc private func moveButtonTapped() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }
}
