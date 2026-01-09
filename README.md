# VoiceRecorder

iOS 음성 녹음 앱 - MVVM 아키텍처 기반

## 개요

VoiceRecorder는 음성 녹음, 재생, 관리 기능을 제공하는 iOS 앱입니다. 실시간 파형 시각화와 타임라인 기반 녹음 목록을 지원합니다.

## 개발 환경

| 항목 | 버전 |
|------|------|
| Xcode | 26.0+ |
| iOS Deployment Target | 26.0+ |
| Swift | 5.0+ |
| 아키텍처 | MVVM + Combine |

## 사용 프레임워크

### Apple Frameworks
- **UIKit** - UI 구성
- **AVFoundation** - 오디오 녹음/재생
- **Combine** - 반응형 데이터 바인딩

### 외부 라이브러리
- **SnapKit** - Auto Layout DSL (Swift Package Manager)

## 프로젝트 구조

```
VoiceRecorder/
├── App/
│   ├── AppDelegate.swift          # 앱 생명주기 관리
│   └── SceneDelegate.swift        # 씬 생명주기, 루트 뷰 설정
│
├── Common/
│   ├── Extensions/
│   │   ├── TimeInterval+Extension.swift  # 시간 포맷 (formatTime → "00:00")
│   │   └── UIButton+Extension.swift      # 버튼 바운스 애니메이션
│   └── Views/
│       └── BaseWaveformView.swift        # 파형 뷰 공통 베이스 클래스
│
├── Features/
│   ├── MainTabBar/
│   │   └── MainTabBarViewController.swift  # 탭바 컨트롤러 (녹음/목록 탭)
│   │
│   ├── Recording/
│   │   ├── RecordingViewController.swift   # 녹음 화면 UI
│   │   ├── RecordingViewModel.swift        # 녹음 상태/로직 관리
│   │   └── Views/
│   │       └── WaveformView.swift          # 실시간 녹음 파형 표시
│   │
│   ├── Player/
│   │   ├── PlayerViewController.swift      # 재생 화면 UI (모달)
│   │   ├── PlayerViewModel.swift           # 재생 상태/로직 관리
│   │   └── Views/
│   │       └── StaticWaveformView.swift    # 전체 파형 + 진행률 표시
│   │
│   └── RecordingList/
│       ├── RecordingListViewController.swift  # 녹음 목록 화면 UI
│       ├── RecordingListViewModel.swift       # 목록 데이터 관리
│       └── Views/
│           ├── TimelineGraphView.swift        # 타임라인 그래프 뷰
│           └── TimelineRowView.swift          # 녹음 항목 행 뷰
│
├── Models/
│   └── Recording.swift            # 녹음 데이터 모델 (id, url, duration 등)
│
├── Services/
│   ├── AudioRecorderService.swift      # 녹음 기능 (AVAudioRecorder)
│   ├── AudioPlayerService.swift        # 재생 기능 (AVAudioPlayer)
│   └── RecordingStorageService.swift   # 파일 저장/조회/삭제
│
└── Assets/
    └── Assets.xcassets           # 커스텀 색상
```

## 주요 기능

### 1. 녹음 (Recording)
- 실시간 오디오 녹음
- 일시정지/재개 지원
- 실시간 파형 시각화 (오른쪽 → 왼쪽)
- 녹음 시간 표시

### 2. 재생 (Player)
- 녹음 파일 재생
- 재생/일시정지 토글
- 10초 앞/뒤 건너뛰기
- 시크바를 통한 위치 이동
- 전체 파형 + 진행률 표시

### 3. 녹음 목록 (Recording List)
- 타임라인 기반 녹음 목록
- 녹음 선택 시 Player 모달 표시

## 아키텍처

### MVVM + Combine

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│      View       │────▶│   ViewModel     │────▶│    Service      │
│ (ViewController)│◀────│  (@Published)   │◀────│   (Singleton)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │    UI Events          │    Business Logic     │    Data/Audio
        │    Data Binding       │    State Management   │    Operations
```

### 데이터 바인딩 예시

```swift
// ViewModel
@Published private(set) var isRecording: Bool = false
@Published private(set) var elapsedTime: TimeInterval = 0

// ViewController
viewModel.$isRecording
    .receive(on: DispatchQueue.main)
    .sink { [weak self] isRecording in
        self?.updateRecordButton(isRecording)
    }
    .store(in: &cancellables)
```

## 빌드 및 실행

### 요구사항
- macOS 26.0+
- Xcode 26.0+
- iOS 26.0+ 디바이스 또는 시뮬레이터

### 빌드 방법

1. 저장소 클론
```bash
git clone https://github.com/minji0801/VoiceRecorder
cd VoiceRecorder
```

2. Xcode에서 프로젝트 열기
```bash
open VoiceRecorder.xcodeproj
```

3. Swift Package 의존성 자동 설치 (SnapKit)

4. 빌드 및 실행
   - 시뮬레이터 또는 실제 디바이스 선택
   - `Cmd + R` 또는 Run 버튼 클릭

### 권한 설정

앱 실행 시 다음 권한이 필요합니다:
- **마이크 접근** - 음성 녹음을 위해 필요

Info.plist에 설정된 항목:
- `UIBackgroundModes: audio` - 백그라운드 오디오 녹음
- `UIFileSharingEnabled: true` - 파일 공유 활성화

## 파일 저장 위치

녹음 파일은 파일 앱에서 다음 경로로 접근할 수 있습니다:
```
나의 iPhone → VoiceRecorder → Recording_YYYY-MM-DD_HH-mm-ss.m4a
```

| 경로 | 설명 |
|------|------|
| 나의 iPhone/VoiceRecorder | 앱의 Documents 폴더 |
| Recording_*.m4a | 녹음 파일 (AAC 포맷) |
