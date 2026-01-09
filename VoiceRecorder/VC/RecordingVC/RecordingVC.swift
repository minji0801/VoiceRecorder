//
//  RecordingVC.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import UIKit
import SnapKit
import Combine

final class RecordingVC: UIViewController {
  
  // MARK: - Properties

  // 타임 라벨
  private let timerLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 60, weight: .light)
    label.text = "00:00"
    label.textColor = .white
    return label
  }()
  
  // 오디오 레벨 뷰
  private let waveformView = WaveformView()
  
  // 레코딩 버튼
  private lazy var recordButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .customRed
    button.tintColor = .white
    button.layer.cornerRadius = 40
    button.layer.borderWidth = 4
    button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // 일시정지 버튼
  private lazy var pauseButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "pause.fill", withConfiguration: iconConfig), for: .normal)
    button.tintColor = .white
    button.backgroundColor = .customPurple
    button.layer.cornerRadius = 28
    button.isHidden = true
    button.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
    return button
  }()
  
  private let viewModel = RecordingViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  private let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
  
  // MARK: - Lifesycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    setupBindings()
    requestMicPermission()
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    view.backgroundColor = .customBlack
    
    view.addSubview(timerLabel)
    view.addSubview(waveformView)
    view.addSubview(recordButton)
    view.addSubview(pauseButton)
  }
  
  private func setupConstraints() {
    waveformView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.center.equalToSuperview()
      make.height.equalTo(120)
    }
    timerLabel.snp.makeConstraints { make in
      make.bottom.equalTo(waveformView.snp.top).offset(-40)
      make.centerX.equalToSuperview()
    }
    recordButton.snp.makeConstraints { make in
      make.top.equalTo(waveformView.snp.bottom).offset(40)
      make.centerX.equalToSuperview()
      make.size.equalTo(80)
    }
    pauseButton.snp.makeConstraints { make in
      make.leading.equalTo(recordButton.snp.trailing).offset(40)
      make.centerY.equalTo(recordButton)
      make.size.equalTo(56)
    }
  }
  
  private func setupBindings() {
    viewModel.$elapsedTime
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.timerLabel.text = self?.viewModel.elapsedTime.formatTime
      }
      .store(in: &cancellables)
    
    viewModel.$audioLevel
      .receive(on: DispatchQueue.main)
      .sink { [weak self] level in
        guard let self = self, self.viewModel.state == .recording else { return }
        self.waveformView.addLevel(level)
      }
      .store(in: &cancellables)
    
    viewModel.$state
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.updateUI(state)
      }
      .store(in: &cancellables)
  }
  
  private func requestMicPermission() {
    viewModel.requestPermission { grated in
      if !grated {
        print("마이크 권한 거부됨")
        // TODO: 권한 거부 시 UI/UX
      }
    }
  }
  
  private func updateUI(_ state: RecordingState) {
    switch state {
      case .idle:
        recordButton.backgroundColor = .customRed
        recordButton.setImage(nil, for: .normal)
        pauseButton.isHidden = true
        timerLabel.text = "00:00"
        waveformView.reset()
        
      case .recording:
        recordButton.backgroundColor = .customGray
        recordButton.setImage(UIImage(systemName: "square.fill"), for: .normal)
        pauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: iconConfig), for: .normal)
        pauseButton.backgroundColor = .customPurple
        pauseButton.isHidden = false
        
      case .paused:
        pauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: iconConfig), for: .normal)
        pauseButton.backgroundColor = .customCyan
    }
  }
  
  // MARK: - Actions
  
  @objc private func recordButtonTapped() {
    recordButton.animateBounce { [weak self] in
      guard let self = self else { return }
      
      switch self.viewModel.state {
        case .idle:
          do {
            try self.viewModel.startRecording()
            self.waveformView.reset()
          } catch {
//            showAlert(title: "녹음 오류", message: error.localizedDescription)
          }
        case .recording, .paused:
          self.viewModel.stopRecording()
      }
    }
  }
  
  @objc private func pauseButtonTapped() {
    pauseButton.animateBounce { [weak self] in
      guard let self = self else { return }
      self.viewModel.togglePause()
    }
  }
}
