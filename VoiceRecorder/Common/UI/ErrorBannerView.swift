//
//  ErrorBannerView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/14/26.
//  재사용 가능한 에러 배너 뷰

import UIKit
import SnapKit

final class ErrorBannerView: UIView {
  
  // MARK: - Properties
  
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .medium)
    label.textColor = .white
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  private var hideTimer: Timer?
  
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
    layer.cornerRadius = 12
    clipsToBounds = true
    alpha = 0
    isHidden = true
    
    addSubview(messageLabel)
    
    messageLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(16)
    }
  }
  
  // MARK: - Public Methods
  
  /// 에러 메시지 표시
  /// - Parameters:
  ///   - message: 표시할 메시지
  ///   - autoDismiss: 자동 숨김 여부 (기본: true)
  ///   - duration: 자동 숨김 시간 (기본: 3초)
  func show(message: String, autoDismiss: Bool = true, duration: TimeInterval = 3.0) {
    hideTimer?.invalidate()
    messageLabel.text = message
    isHidden = false
    
    UIView.animate(withDuration: 0.3) {
      self.alpha = 1
    }
    
    if autoDismiss {
      hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
        self?.hide()
      }
    }
  }
  
  /// 에러 배너 숨기기
  func hide() {
    hideTimer?.invalidate()
    hideTimer = nil
    
    UIView.animate(withDuration: 0.3) {
      self.alpha = 0
    } completion: { _ in
      self.isHidden = true
    }
  }
  
  /// LocalizedError 표시 (편의 메서드)
  func show(error: Error, autoDismiss: Bool = true, duration: TimeInterval = 3.0) {
    show(message: error.localizedDescription, autoDismiss: autoDismiss, duration: duration)
  }
}
