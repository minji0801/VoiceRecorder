# VoiceRecorder

iOS 음성 녹음 앱

## 주요 기능

- **녹음**: 음질 선택 (저음질/중음질/고음질), 일시정지/재개 지원
- **재생**: 파형 시각화, 10초 앞/뒤 스킵, 프로그레스 바 탐색
- **녹음 목록**: 타임라인 그래프로 녹음 시간대 시각화

## 프로젝트 구조

```
VoiceRecorder/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Models/
│   ├── Recording.swift          # 녹음 데이터 모델
│   ├── AudioQuality.swift       # 음질 설정 (low/medium/high)
│   └── AppError.swift           # 커스텀 에러 정의
├── Services/
│   ├── AudioRecorderService.swift    # 녹음 기능
│   ├── AudioPlayerService.swift      # 재생 기능
│   └── RecordingStorageService.swift # 파일 저장/조회/삭제
├── Features/
│   ├── Recording/               # 녹음 화면
│   ├── Player/                  # 재생 화면
│   ├── RecordingList/           # 녹음 목록 화면
│   └── MainTabBar/              # 탭바 컨트롤러
└── Common/
    ├── UI/
    │   ├── BaseWaveformView.swift    # 파형 뷰 베이스 클래스
    │   ├── BounceButton.swift        # 애니메이션 버튼
    │   └── ErrorBannerView.swift     # 에러 배너 뷰
    └── Extensions/
        └── TimeInterval+Extension.swift
```

## 아키텍처

**MVVM + Service Layer**

```
View (ViewController) ← ViewModel ← Service
         ↓                  ↓
     UI 업데이트        비즈니스 로직
```

- **ViewController**: UI 표시, 사용자 입력 처리
- **ViewModel**: 상태 관리, Combine으로 바인딩
- **Service**: 오디오 녹음/재생, 파일 관리

## 기술 스택

| 카테고리 | 기술 |
|---------|------|
| UI | UIKit, SnapKit |
| 반응형 | Combine |
| 오디오 | AVFoundation |
| 패턴 | MVVM |

## 음질 설정

| 음질 | 샘플레이트 | 비트레이트 | 채널 |
|-----|-----------|-----------|------|
| 저음질 | 22,050 Hz | 64 kbps | 모노 |
| 중음질 | 44,100 Hz | 128 kbps | 스테레오 |
| 고음질 | 48,000 Hz | 256 kbps | 스테레오 |

## 에러 처리

사용자 친화적인 한국어 에러 메시지 제공:

```swift
enum RecordingError: LocalizedError {
  case permissionDenied    // "마이크 접근 권한이 필요합니다..."
  case sessionSetupFailed  // "오디오 세션을 시작할 수 없습니다..."
  case recorderInitFailed  // "녹음기를 초기화할 수 없습니다..."
  case recordingFailed     // "녹음을 시작할 수 없습니다..."
}

enum PlaybackError: LocalizedError {
  case fileNotFound        // "녹음 파일을 찾을 수 없습니다..."
  case invalidFormat       // "지원하지 않는 오디오 형식입니다"
  case playerInitFailed    // "재생기를 초기화할 수 없습니다..."
}
```

## 개발환경

- iOS 18.0+
- Xcode 26.0+
- Swift 6.0+

## 의존성

- [SnapKit](https://github.com/SnapKit/SnapKit) - Auto Layout DSL

## 라이선스

Private Project
