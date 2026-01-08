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
    button.backgroundColor = .systemRed
    button.layer.cornerRadius = 40
    button.layer.borderWidth = 4
    button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    return button
  }()
  
  private let audioRecordManager = AudioRecordManager()
  private var cancellables = Set<AnyCancellable>()
  
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
    view.backgroundColor = .systemBackground
    
    view.addSubview(timerLabel)
    view.addSubview(waveformView)
    view.addSubview(recordButton)
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
  }
  
  private func setupBindings() {
    audioRecordManager.$elapsedTime
      .receive(on: DispatchQueue.main)
      .sink { [weak self] elapsedTime in
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        self?.timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
      }
      .store(in: &cancellables)
    
    audioRecordManager.$audioLevel
      .receive(on: DispatchQueue.main)
      .sink { [weak self] level in
        guard let self = self, audioRecordManager.isRecording else { return }
        self.waveformView.addLevel(level)
      }
      .store(in: &cancellables)
    
    audioRecordManager.$isRecording
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isRecording in
        if isRecording {
          self?.recordButton.backgroundColor = .systemGray
          self?.waveformView.reset()
        } else {
          self?.recordButton.backgroundColor = .systemRed
          self?.timerLabel.text = "00:00"
        }
      }
      .store(in: &cancellables)
  }
  
  private func requestMicPermission() {
    audioRecordManager.requestPermission { grated in
      if !grated {
        print("마이크 권한 거부됨")
        // TODO: 권한 거부 시 UI/UX
      }
    }
  }
  
  // MARK: - Actions
  
  @objc private func recordButtonTapped() {
    recordButton.animateBounce { [weak self] in
      guard let self = self else { return }
      
      if audioRecordManager.isRecording {
        self.audioRecordManager.stopRecording()
      } else {
        self.audioRecordManager.startRecording()
      }
    }
  }
}
