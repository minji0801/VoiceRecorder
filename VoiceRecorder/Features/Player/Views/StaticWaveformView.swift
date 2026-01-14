//
//  StaticWaveformView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/9/26.
//  전체 파형 + 진행률 표시

import UIKit
import AVFoundation

final class StaticWaveformView: BaseWaveformView {

  // MARK: - Properties

  private var samples: [Float] = []

  var progress: CGFloat = 0 {
    didSet {
      progress = max(0, min(1, progress))
      setNeedsDisplay()
    }
  }

  // MARK: - Public Methods

  func loadSamples(from url: URL, completion: @escaping ([Float]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }

      do {
        let samples = try self.extractSamples(from: url, sampleCount: 100)
        DispatchQueue.main.async {
          self.samples = samples
          self.setNeedsDisplay()
          completion(samples)
        }
      } catch {
        DispatchQueue.main.async {
          self.samples = []
          self.setNeedsDisplay()
          completion([])
        }
      }
    }
  }

  func reset() {
    samples = []
    progress = 0
    setNeedsDisplay()
  }

  // MARK: - Private Methods

  private func extractSamples(from url: URL, sampleCount: Int) throws -> [Float] {
    let file = try AVAudioFile(forReading: url)
    let format = file.processingFormat
    let frameCount = UInt32(file.length)

    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
      return []
    }

    try file.read(into: buffer)

    guard let floatChannelData = buffer.floatChannelData,
          format.channelCount > 0 else {
      return []
    }

    let channelData = floatChannelData[0]
    let stride = max(1, Int(frameCount) / sampleCount)

    var samples: [Float] = []
    for i in Swift.stride(from: 0, to: Int(frameCount), by: stride) {
      let sample = abs(channelData[i])
      samples.append(sample)
    }

    let maxSample = samples.max() ?? 1
    if maxSample > 0 {
      samples = samples.map { $0 / maxSample }
    }

    return Array(samples.prefix(sampleCount))
  }

  // MARK: - Drawing

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    prepareContext(context, in: rect)

    guard !samples.isEmpty else {
      drawPlaceholderBars(in: rect, context: context)
      return
    }

    let centerY = rect.height / 2
    let maxHeight = rect.height * maxHeightRatio
    let progressX = startX + (rect.width - padding) * progress

    for (index, sample) in samples.enumerated() {
      let x = startX + CGFloat(index) * totalBarWidth + barWidth / 2

      if x > rect.width - startX { break }

      let height = calculateBarHeight(for: sample, maxHeight: maxHeight)

      // 진행된 부분은 그라데이션, 나머지는 비활성 색상
      let color: UIColor
      if x <= progressX {
        let colorProgress = CGFloat(index) / CGFloat(max(1, samples.count - 1))
        color = interpolateColor(from: gradientStartColor, to: gradientEndColor, progress: colorProgress)
      } else {
        color = inactiveColor
      }

      drawBar(context: context, at: x, centerY: centerY, height: height, color: color)
    }
  }
}
