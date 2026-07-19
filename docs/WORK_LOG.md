# 작업 현황

## 현재 상태

- 현재 마일스톤: M1 — 실행 가능한 세로형 게임 셸 완료
- 다음 마일스톤: M2 — 이동, 카메라, 필드
- 마지막 갱신: 2026-07-19

## 완료

- 원본 게임 아이디어를 1차 프로토타입 명세로 구조화
- Flutter + Flame 기술 방향 확정
- Android/iOS 출시 및 Web 테스트 목표 반영
- 전체 픽셀아트 방향과 에셋 제작 계획 작성
- 구현 아키텍처와 테스트 전략 작성
- M0~M9 로드맵 작성
- 결정 기록 형식 도입
- Git 저장소 초기화
- 앱 식별자 `com.roycekim.fishgrowthrpg` 확정
- Flutter Android/iOS/Web 프로젝트 생성
- Flame 1.37.0 설치 및 잠금
- 세로 화면 고정과 360×640 논리 해상도 카메라 구성
- Flame World와 임시 픽셀 물고기/배경 구성
- Flutter HUD 오버레이 구성
- 초기 물고기 3종 JSON과 로더 구현
- 단위 및 위젯 테스트 2개 작성
- 정적 분석, 테스트, Web release build 통과
- Android debug APK 빌드 통과

## 진행 중

- M2 드래그 입력 설계 준비

## 다음 작업

- M2 드래그 입력과 PlayerController 구현
- 가속, 관성, 감속 구현
- 부스터와 필드 경계 구현
- Web 및 Android 조작 검증

## 블로커/미결정

- 플레이어 시작 종의 정확한 이름과 초기 스탯
- iOS 빌드 환경: 설치된 CoreSimulator 1051.54.0이 Xcode 요구 버전 1051.55.0보다 낮음
- iOS simulator 서명 대상 Flutter.framework에 macOS resource fork/metadata 오류 존재
- 현재 연결된 모바일 기기가 없어 실제 터치 실행 확인은 후속 검증 필요
