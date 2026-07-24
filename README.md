# Fish Adventure RPG Prototype

Flutter와 Flame으로 제작하는 모바일 세로형 2D 픽셀아트 물고기 탐험 어드벤처 RPG다.

현재 빌드는 기존 성장/사냥 프로토타입 위에 탐험 중심 구조로 전환 중이다. 기준 경험은 `Explore -> Discover -> Unlock -> Explore Again`이다.

## 목표 플랫폼

- Android / Google Play
- iOS / App Store
- Web / 개발 및 QA 테스트

## Web Alpha

- 플레이 링크: [Fish Adventure RPG Web Alpha](https://roycekim84.github.io/fish-growth-rpg/)
- 저장소: [roycekim84/fish-growth-rpg](https://github.com/roycekim84/fish-growth-rpg)
- `main`에 반영된 검증 통과 버전이 GitHub Pages로 자동 배포된다.

## 문서

- [Master Spec](docs/MASTER_SPEC.md)
- [기획 전환 계획](docs/PIVOT_PLAN.md)
- [Legacy 1차 프로토타입 명세](PROJECT_SPEC.md)
- [기술 구현 계획](docs/TECHNICAL_PLAN.md)
- [픽셀아트 및 이미지 에셋 계획](docs/ART_ASSET_PLAN.md)
- [개발 로드맵](docs/ROADMAP.md)
- [결정 기록](docs/DECISIONS.md)
- [작업 현황](docs/WORK_LOG.md)
- [Web Alpha 배포](docs/DEPLOYMENT.md)

## 진행 원칙

1. 문서에서 현재 마일스톤과 완료 조건을 확인한다.
2. 기능을 작은 Git 커밋 단위로 구현한다.
3. 분석, 테스트, 웹 빌드를 통과시킨다.
4. 작업 현황과 결정 기록을 갱신한다.
5. 모바일 실기기 확인 없이 마일스톤을 최종 완료 처리하지 않는다.

`M13 — Adventure Alpha Vertical Slice`까지 완료했다. 얕은 바다에서 발견·퀘스트·종 능력·수문장 보스·심해 진입으로 이어지는 첫 탐험 루프가 동작하며, 다음 단계는 심해 전용 생태계와 추가 지역을 만드는 일이다.
