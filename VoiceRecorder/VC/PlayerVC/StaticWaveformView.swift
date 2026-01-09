//
//  StaticWaveformView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/9/26.
//

import UIKit
import AVFoundation

final class StaticWaveformView: UIView {
  
  // MARK: - Properties
  
  var waveColor: UIColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0) {
    didSet { setNeedsDisplay() }
  }
  
  var progressColor: UIColor = UIColor(red: 0.55, green: 0.45, blue: 0.85, alpha: 1.0) {
    didSet { setNeedsDisplay() }
  }
  
  var progress: CGFloat = 0 {
    didSet {
      progress = max(0, min(1, progress))
      setNeedsDisplay()
    }
  }
  
  private var samples: [Float] = []
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    backgroundColor = .clear
    isOpaque = false
    layer.cornerRadius = 12
    clipsToBounds = true
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
    
    guard let floatChannelData = buffer.floatChannelData else {
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
    
    let bgColor = UIColor(red: 0.08, green: 0.09, blue: 0.15, alpha: 1.0)
    context.setFillColor(bgColor.cgColor)
    context.fill(rect)
    
    guard !samples.isEmpty else { return }
    
    let barWidth: CGFloat = 3
    let spacing: CGFloat = 3
    let totalBarWidth = barWidth + spacing
    let startX: CGFloat = 16
    let centerY = rect.height / 2
    let maxHeight = rect.height * 0.7
    
    let progressX = startX + (rect.width - 32) * progress
    
    context.setLineCap(.round)
    context.setLineWidth(barWidth)
    
    for (index, sample) in samples.enumerated() {
      let x = startX + CGFloat(index) * totalBarWidth + barWidth / 2
      
      if x > rect.width - 16 { break }
      
      let scaledSample = pow(CGFloat(sample), 0.7)
      let barHeight = max(4, scaledSample * maxHeight)
      
      let startY = centerY - barHeight / 2
      let endY = centerY + barHeight / 2
      
      if x <= progressX {
        let progressRatio = CGFloat(index) / CGFloat(max(1, samples.count - 1))
        let startColor = UIColor(red: 0.55, green: 0.45, blue: 0.85, alpha: 1.0)
        let endColor = UIColor(red: 0.65, green: 0.6, blue: 0.95, alpha: 1.0)
        let color = interpolateColor(from: startColor, to: endColor, progress: progressRatio)
        context.setStrokeColor(color.cgColor)
      } else {
        context.setStrokeColor(waveColor.cgColor)
      }
      
      context.move(to: CGPoint(x: x, y: startY))
      context.addLine(to: CGPoint(x: x, y: endY))
      context.strokePath()
    }
  }
  
  private func interpolateColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
    var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
    var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0
    
    from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
    to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
    
    let r = fromR + (toR - fromR) * progress
    let g = fromG + (toG - fromG) * progress
    let b = fromB + (toB - fromB) * progress
    let a = fromA + (toA - fromA) * progress
    
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}

