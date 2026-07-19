# 기술 구현 계획

## 1. 기술 기준선

- UI/App: Flutter stable
- Game engine: Flame
- Language: Dart
- 주 플랫폼: Android, iOS
- 보조 테스트 플랫폼: Flutter Web
- 화면 방향: portrait only
- 버전 관리: Git

로컬에서 확인한 개발 기준선은 Flutter 3.44.0, Dart 3.12.0, Flame 1.37.0이다. `pubspec.lock`을 커밋해 실제 Flame 및 플러그인 버전을 고정한다.

## 2. 책임 분리

### Flutter 영역

- 앱 시작과 수명주기
- `GameWidget` 호스팅
- HUD, 일시정지, 도감, 종변화, 설정 화면
- 접근성 및 SafeArea
- 로컬 저장 연결
- 플랫폼별 설정과 배포

### Flame 영역

- 고정 timestep에 가까운 프레임 독립 게임 업데이트
- World와 CameraComponent
- 플레이어 및 NPC Component
- 이동, AI, 충돌, 포식과 전투
- 스프라이트 애니메이션과 파티클
- 스폰과 디스폰

### 순수 Dart 도메인 영역

- 종 데이터
- 스탯 계산
- 경험치와 레벨업
- 포식 카운트와 해금 조건
- 저장 모델과 마이그레이션

도메인 규칙을 Flame Component와 분리해 단위 테스트가 가능하도록 한다.

## 3. 화면과 좌표계

- 기준 논리 해상도 후보: `360 × 640` 세로 비율
- 실제 기기에서는 종횡비에 맞게 보이는 월드 영역을 확장하고 SafeArea를 반영
- 카메라는 플레이어를 부드럽게 추적
- 픽셀아트는 정수 배율을 우선하되 다양한 모바일 비율에서는 화면 잘림보다 월드 추가 노출을 허용
- 픽셀 스프라이트에는 nearest-neighbor 계열 필터와 정수 좌표 스냅 정책 적용
- 게임 로직의 월드 단위와 원본 에셋 픽셀 수는 분리

웹 테스트는 세로형 게임 캔버스를 가운데 배치하고 주변에 개발용 여백을 둔다. 웹 전체 화면 방향 고정 기능에 의존하지 않는다.

## 4. 입력 설계

- 터치/포인터 드래그를 하나의 포인터 입력 계층으로 통합
- 모바일: 손가락 드래그 + 부스터 버튼
- 웹: 마우스 드래그 + 부스터 버튼, 선택적으로 Space 키를 부스터 디버그 입력으로 제공
- UI 위에서 시작된 포인터는 월드 이동 입력으로 전달하지 않음
- 입력 벡터, 현재 추진력, 부스터 상태를 PlayerController가 소유

M2 기준 이동 파라미터:

- 가속도: 360 logical pixels/s²
- 기본 최대 속도: 135 logical pixels/s
- 부스터 배율: 1.65
- 드래그 데드존: 10 logical pixels
- 입력 해제 후 지수 감속으로 관성 유지
- 프레임 지연 시 한 번에 적용하는 이동 delta 최대 1/20초
- 카메라 추적 최대 속도: 420 logical pixels/s

입력 시작점을 드래그 앵커로 저장하고 현재 포인터와 앵커 사이의 방향을 추진 방향으로 사용한다. 화면 밖 포인터 좌표가 유효하지 않을 때는 마지막 정상 입력을 유지하고, 손을 떼면 추진만 중단하며 속도는 관성으로 감속한다.

## 5. Flame 컴포넌트 설계

```text
FishGame extends FlameGame
├── FishWorld
│   ├── PlayerFish
│   ├── NpcFish[]
│   ├── SpawnSystem
│   └── WorldBoundary
├── CameraComponent
└── Debug/Telemetry
```

권장 믹스인/기능:

- 위치·크기·회전: `PositionComponent` 또는 `SpriteAnimationComponent`
- 충돌: Flame collision detection
- 입력: Drag/Pointer callback 계층
- UI: `GameWidget.overlayBuilderMap`
- 화면 추적: `CameraComponent`와 viewfinder follow

구체 API는 실제로 설치된 Flame 버전의 문서와 컴파일 결과를 기준으로 확정한다.

## 6. 데이터와 상태 흐름

```text
JSON/asset species definitions
  → SpeciesRepository
  → GameSession / PlayerProgress
  → Flame systems update state
  → ValueNotifier/ChangeNotifier adapter
  → Flutter HUD and overlays
```

- 고빈도 위치와 속도는 Flame 내부에 유지
- HP, Fullness, EXP처럼 UI가 읽는 값만 변경 이벤트로 전달
- 저장은 런타임 Component를 직렬화하지 않고 PlayerSaveData만 직렬화
- 게임 시스템은 종 ID에 따른 `switch` 남발 대신 데이터와 trait 등록소를 사용

## 7. 로컬 저장

초기 후보는 경량 key-value 저장소다. 저장 라이브러리는 웹·Android·iOS 지원, 유지보수 상태, 마이그레이션 가능성을 확인한 후 M1에서 확정한다.

- JSON 직렬화 가능한 PlayerSaveData
- `schemaVersion` 필수
- 중요한 진행 이벤트 후 디바운스 저장
- 앱 pause/inactive 시 즉시 저장 요청
- UTC ISO-8601 마지막 저장 시간
- 웹 저장은 테스트 편의용이며 모바일 영구 저장의 완전한 대체로 간주하지 않음

## 8. 테스트 전략

### 자동 테스트

- unit: 레벨업, 최종 스탯, 포식 판정, 회복, 해금, 저장 마이그레이션
- widget: HUD, 도감, 종변화 잠금/선택 상태
- game/component: 이동 경계, 충돌 쿨다운, 중복 보상, 스폰 거리
- golden: 핵심 세로 화면과 픽셀 UI

### 수동 테스트

- Web Chrome: 빠른 기능 확인
- Android 에뮬레이터 및 실기기: 터치, 성능, 백그라운드 복귀
- iOS Simulator 및 실기기: SafeArea, 앱 수명주기, 성능
- 작은 화면, 긴 화면, 노치/홈 인디케이터 조합

### 기본 품질 게이트

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build web
```

마켓 배포 단계에서는 Android App Bundle과 iOS archive 빌드를 별도 검증한다.

## 9. 성능 원칙

- 목표: 일반 모바일 기기에서 60 FPS
- AI 의사 결정과 스폰 검사는 렌더 프레임보다 낮은 주기로 실행
- 화면 밖 개체의 애니메이션/AI 비용 축소 고려
- 반복 생성되는 파티클과 NPC는 필요 시 객체 풀 사용
- 큰 투명 PNG와 과도한 레이어 방지
- 아틀라스 단위 로딩 및 첫 화면 필수 에셋 선로딩
- 웹 성능은 회귀 탐지에 사용하되 모바일 프로파일 결과를 최종 기준으로 사용

M3 NPC 기준:

- 총 활성 NPC: SmallFish 30, PufferFish 10, HunterFish 5
- 플레이어 최소 스폰 거리: 280 logical pixels
- NPC 간 최소 초기 거리: 28 logical pixels
- 감지 거리: 220 logical pixels
- 가까운 NPC 상태 판단: 0.15초 주기
- 먼 NPC 상태 판단: 0.6초 주기
- 이동과 방향 보간: 매 프레임
- 누락 개체 보충 검사: 1초 주기

M4 전투 기준:

- 플레이어 임시 MaxHP/STR/Size: 40/3/0.8
- 플레이어와 NPC는 원형 hitbox를 사용
- Size 1.15배 이상은 즉시 포식, 0.9배 미만은 플레이어 위험, 사이는 상호 피해
- 피해량은 공격자의 STR, 같은 접촉 대상의 물기 간격은 0.75초
- NPC의 `markConsumed` 상태로 중복 보상 방지
- 플레이어 사망 시 월드 중앙 완전 회복 및 1.5초 접촉 무적
- 위험도 링은 초록/노랑/빨강으로 렌더링하고 색 외 HP 바를 함께 제공

M4.5 반자동 사냥 기준:

- `AutoHuntSystem`이 게임 상태와 자동 대상 수명주기를 소유
- `AutoHuntRules`는 최근접 포식 대상과 위험 반경을 순수 Dart로 판정
- 대상 재탐색 주기 0.15초, 자동 최대 속도는 기본의 75%
- 위험 중단 거리 150 logical pixels, 저체력 기준 MaxHP의 35%
- 위험·저체력 중단은 자동 추진 관성을 제거
- 수동 드래그, 부스터, KO는 AUTO 상태를 즉시 해제
- Flutter HUD는 `ValueNotifier`로 ON/OFF와 SEARCH/HUNT/중단 사유를 표시

## 10. 플랫폼 및 출시 준비

- Android application ID와 iOS bundle ID는 M1에서 확정
- Android 최소/대상 SDK, iOS 최소 버전은 적용 시점의 Flutter 및 마켓 정책 확인 후 고정
- 서명 키와 인증서는 저장소에 커밋하지 않음
- 개인정보 수집 없음이 기본이나 스토어 선언은 실제 플러그인과 기능 기준으로 검토
- 앱 아이콘, 스플래시, 스크린샷, 개인정보처리방침 URL은 출시 마일스톤에서 준비
- 웹 빌드는 내부 QA 또는 공개 데모용으로 배포 가능

## 11. 예상 프로젝트 구조

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── lifecycle/
├── game/
│   ├── fish_game.dart
│   ├── world/
│   ├── components/
│   ├── controllers/
│   └── systems/
├── domain/
│   ├── models/
│   ├── rules/
│   └── repositories/
├── data/
│   ├── species/
│   └── save/
└── ui/
    ├── hud/
    ├── codex/
    └── species_change/

assets/
├── data/
├── images/
│   ├── backgrounds/
│   ├── fish/
│   ├── effects/
│   └── ui/
└── audio/

test/
├── domain/
├── game/
└── ui/
```
