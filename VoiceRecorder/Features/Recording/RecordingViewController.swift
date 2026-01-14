//
//  RecordingViewController.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  녹음 화면 UI

import UIKit
import SnapKit
import Combine

final class RecordingViewController: UIViewController {
  
  // MARK: - Properties
  
  // 권한 거절 시 - 권한 요청 뷰
  private let permissionView = PremissionRequstView()
  
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
  private lazy var recordButton: BounceButton = {
    let button = BounceButton()
    button.backgroundColor = .customRed
    button.tintColor = .white
    button.layer.cornerRadius = 40
    button.layer.borderWidth = 4
    button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // 일시정지 버튼
  private lazy var pauseButton: BounceButton = {
    let button = BounceButton()
    button.setImage(UIImage(systemName: "pause.fill", withConfiguration: iconConfig), for: .normal)
    button.tintColor = .white
    button.backgroundColor = .customPurple
    button.layer.cornerRadius = 28
    button.isHidden = true
    button.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
    return button
  }()
  
  // 음질 설정
  private lazy var qualitySegment: UISegmentedControl = {
    let items = AudioQuality.allCases.map { $0.displayName }
    let segment = UISegmentedControl(items: items)
    segment.selectedSegmentIndex = 1
    segment.backgroundColor = .customNavy
    segment.selectedSegmentTintColor = .customPurpleDark
    segment.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.6)], for: .normal)
    segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    segment.addTarget(self, action: #selector(qualityChanged), for: .valueChanged)
    return segment
  }()
  
  private let viewModel = RecordingViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  private let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    setupBindings()
    checkMicPermission()
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    view.backgroundColor = .customBlack
    
    view.addSubview(permissionView)
    view.addSubview(timerLabel)
    view.addSubview(waveformView)
    view.addSubview(qualitySegment)
    view.addSubview(recordButton)
    view.addSubview(pauseButton)
    
    permissionView.isHidden = true
  }
  
  private func setupConstraints() {
    permissionView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(60)
    }
    
    waveformView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-40)
      make.height.equalTo(120)
    }
    
    timerLabel.snp.makeConstraints { make in
      make.bottom.equalTo(waveformView.snp.top).offset(-40)
      make.centerX.equalToSuperview()
    }
    
    qualitySegment.snp.makeConstraints { make in
      make.top.equalTo(waveformView.snp.bottom).offset(30)
      make.leading.trailing.equalTo(waveformView)
      make.height.equalTo(50)
    }
    
    recordButton.snp.makeConstraints { make in
      make.top.equalTo(qualitySegment.snp.bottom).offset(40)
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
  
  private func checkMicPermission() {
    viewModel.checkPermission { [weak self] grated in
      self?.timerLabel.alpha = grated ? 1.0 : 0.5
      self?.recordButton.isEnabled = grated
      self?.recordButton.alpha = grated ? 1.0 : 0.5
      self?.permissionView.isHidden = grated
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
  
  @objc private func qualityChanged(_ sender: UISegmentedControl) {
    let quality = AudioQuality.allCases[sender.selectedSegmentIndex]
    viewModel.setQuality(quality)
  }
  
  @objc private func recordButtonTapped() {
    switch viewModel.state {
      case .idle:
        do {
          try viewModel.startRecording()
          waveformView.reset()
        } catch {
          //            showAlert(title: "녹음 오류", message: error.localizedDescription)
        }
      case .recording, .paused:
        viewModel.stopRecording()
    }
  }
  
  @objc private func pauseButtonTapped() {
    viewModel.togglePause()
  }
}
