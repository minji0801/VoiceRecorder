//
//  WaveformView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  실시간 녹음 파형 표시

import UIKit

final class WaveformView: BaseWaveformView {

  // MARK: - Properties

  private var levels: [Float] = []

  // MARK: - Public Methods

  func addLevel(_ level: Float) {
    levels.append(level)

    if levels.count > maxBars {
      levels.removeFirst()
    }

    setNeedsDisplay()
  }

  func reset() {
    levels.removeAll()
    setNeedsDisplay()
  }

  func setLevels(_ newLevels: [Float]) {
    levels = newLevels
    setNeedsDisplay()
  }

  // MARK: - Private Methods

  private func getVisibleLevels(for rect: CGRect) -> [Float] {
    let availableWidth = rect.width - padding
    let maxVisibleBars = Int(availableWidth / totalBarWidth)

    if levels.count > maxVisibleBars {
      return Array(levels.suffix(maxVisibleBars))
    }
    return levels
  }

  // MARK: - Drawing

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    prepareContext(context, in: rect)

    guard !levels.isEmpty else {
      drawPlaceholderBars(in: rect, context: context)
      return
    }

    let centerY = rect.height / 2
    let maxHeight = rect.height * maxHeightRatio
    let visibleLevels = getVisibleLevels(for: rect)
    let rightEdge = rect.width - startX

    for (index, level) in visibleLevels.enumerated() {
      let reversedIndex = visibleLevels.count - 1 - index
      let x = rightEdge - CGFloat(reversedIndex) * totalBarWidth - barWidth / 2
      let progress = CGFloat(index) / CGFloat(max(1, visibleLevels.count - 1))
      let color = interpolateColor(from: gradientStartColor, to: gradientEndColor, progress: progress)
      let height = calculateBarHeight(for: level, maxHeight: maxHeight)

      drawBar(context: context, at: x, centerY: centerY, height: height, color: color)
    }
  }
}
