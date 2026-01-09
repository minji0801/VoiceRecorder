//
//  PlayerVC.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/9/26.
//

import UIKit
import SnapKit

final class PlayerVC: UIViewController {

  // MARK: - Recording File Info
  
  // 녹음 파일 정보
  private let infoStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .vertical
      stackView.spacing = 8
      stackView.alignment = .center
      return stackView
  }()

  // 파일이름
  private let recordingNameLabel: UILabel = {
      let label = UILabel()
      label.font = .systemFont(ofSize: 20, weight: .semibold)
      label.textColor = .white
      return label
  }()

  // 생성날짜, 파일 크기
  private let recordingDetailsLabel: UILabel = {
      let label = UILabel()
      label.font = .systemFont(ofSize: 14, weight: .regular)
      label.textColor = .customGray
      return label
  }()
  
  // MARK: - Play Progress

  // 오디오 레벨 뷰
  private let waveformView = StaticWaveformView()
  
  private let progressStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.alignment = .fill
    return stackView
  }()
  
  // 시작시간
  private let currentTimeLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
    label.textColor = .customGray
    return label
  }()
  
  // 총시간
  private let durationLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
    label.textColor = .customGray
    return label
  }()
  
  // 프로그레스바
  private let progressSlider: UISlider = {
    let slider = UISlider()
    slider.minimumValue = 0
    slider.maximumValue = 1
    slider.minimumTrackTintColor = .customPurple
    slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
    return slider
  }()
  
  // MARK: - Play Control
  
  // 버튼 컨트롤
  private let controlsStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.spacing = 40
      stackView.alignment = .center
      return stackView
  }()
  
  // 재생
  private let playButton: UIButton = {
    let button = UIButton()
    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
    button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
    button.tintColor = .white
    button.backgroundColor = .customPurple
    button.layer.cornerRadius = 28
    return button
  }()

  // 뒤로가기
  private let backwardButton: UIButton = {
    let button = UIButton()
    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
    button.setImage(UIImage(systemName: "gobackward.10", withConfiguration: config), for: .normal)
    button.tintColor = .customGray
    return button
  }()
  
  // 앞으로가기
  private let forwardButton: UIButton = {
    let button = UIButton()
    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
    button.setImage(UIImage(systemName: "goforward.10", withConfiguration: config), for: .normal)
    button.tintColor = .customGray
    return button
  }()

  
  private let recording: Recording
  
  // MARK: - Initialization

  init(recording: Recording) {
    self.recording = recording
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    updateUI()
  }
  
  private func setupUI() {
    view.backgroundColor = .customBlack
    
    infoStackView.addArrangedSubview(recordingNameLabel)
    infoStackView.addArrangedSubview(recordingDetailsLabel)
    
    progressStackView.addArrangedSubview(currentTimeLabel)
    progressStackView.addArrangedSubview(progressSlider)
    progressStackView.addArrangedSubview(durationLabel)
    
    controlsStackView.addArrangedSubview(backwardButton)
    controlsStackView.addArrangedSubview(playButton)
    controlsStackView.addArrangedSubview(forwardButton)
    
    view.addSubview(infoStackView)
    view.addSubview(waveformView)
    view.addSubview(progressStackView)
    view.addSubview(controlsStackView)
  }
  
  private func setupConstraints() {
    infoStackView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    waveformView.snp.makeConstraints { make in
      make.top.equalTo(infoStackView.snp.bottom).offset(40)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(120)
    }
    progressStackView.snp.makeConstraints { make in
      make.top.equalTo(waveformView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    controlsStackView.snp.makeConstraints { make in
      make.top.equalTo(progressStackView.snp.bottom).offset(40)
      make.centerX.equalToSuperview()
    }
    playButton.snp.makeConstraints { make in
      make.size.equalTo(56)
    }
    backwardButton.snp.makeConstraints { make in
      make.size.equalTo(44)
    }
    forwardButton.snp.makeConstraints { make in
      make.size.equalTo(44)
    }
  }
  
  private func updateUI() {
    recordingNameLabel.text = recording.name
    recordingDetailsLabel.text = "\(recording.formattedDate) · \(recording.fileSize)"
    waveformView.loadSamples(from: recording.url) { samples in
      
    }
  }
}
