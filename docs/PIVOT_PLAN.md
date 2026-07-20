# 기획 전환 계획

## 전환 요약

기존 프로토타입은 `물고기 성장/사냥` 중심으로 구현되어 있다. 새 기준은 `탐험 어드벤처 RPG`이다.

따라서 현재 구현을 폐기하지 않고 의미를 재정의한다.

- 사냥: 핵심 목표가 아니라 생존, 도감, 퀘스트 재료, 위험 판단 수단
- 레벨: 강함의 목표가 아니라 탐험 안정성 보정
- 종변화: 100마리 반복 해금이 아니라 지역 접근과 플레이 스타일을 바꾸는 핵심 보상
- 도감: 포식 카운트 화면이 아니라 발견, 지역, NPC, 퀘스트 기록의 중심
- 반자동 사냥: 진행 자동화가 아니라 반복 먹이 수집 피로를 줄이는 보조 기능

## 유지할 구현

현재 구현 중 다음은 새 기획에도 그대로 유효하다.

- Flutter + Flame 기반
- 모바일 세로 화면과 Web alpha 배포
- 드래그 이동, 관성, 부스터
- 플레이어 추적 카메라와 필드 경계
- NPC Wander/Flee/Chase AI
- 포식/전투/위험도 판정
- HP와 포만감 기반 회복
- EXP와 Level
- Species 데이터, 종변화 UI, 종별 외형/배율
- 도감 UI의 기본 구조
- 로컬 저장 schema와 migration 전제
- 픽셀아트 에셋 파이프라인
- 오디오/햅틱 feedback service

## 재정의할 구현

### 100마리 포식 해금

현재는 종변화의 주 해금 조건이다. 앞으로는 초기 프로토타입용 collection quest 조건으로 낮춘다.

새 기준:

- 포식 카운트는 도감/퀘스트/업적 지표로 유지
- 종 해금은 Quest, Region discovery, Boss gate, Special encounter가 우선
- 100마리 조건은 일부 species의 collection quest로만 사용

### Fullness 명칭

현재 코드와 UI는 Fullness를 사용한다. 새 기획에서는 Hunger가 자연스럽다.

전환 기준:

- 내부 모델은 당장 깨지 않기 위해 `fullness` 유지
- UI와 문서에서는 Hunger로 점진 전환
- save schema migration 시 `hunger` 또는 `nutrition` 명칭을 검토

### Auto Hunt

현재 AUTO는 안전한 초록 대상만 75% 속도로 추적한다.

새 기준:

- 이름을 장기적으로 `Forage Assist`로 바꾼다.
- 위험 회피, 보스, 지역 이동, 퀘스트 완료를 자동화하지 않는다.
- 탐험 판단은 플레이어가 한다.

### Species

현재 Species는 스탯 배율 중심이다.

새 기준:

- `abilityId`
- `movementType`
- `regionAccessTags`
- `questUnlockId`
- `playStyleDescription`

위 필드를 추가할 수 있는 데이터 구조로 확장한다.

## 새로 추가할 핵심 시스템

### Region

각 지역은 별도 데이터로 관리한다.

초기 필드:

- id
- displayName
- paletteId
- biomeType
- discoveryPoints
- completionPercent
- unlocked
- entryRequirements
- bossId
- speciesPool
- npcPool
- propSet

### Discovery

탐험 보상을 수치화한다.

Discovery event examples:

- 새 지역 진입
- 랜드마크 발견
- 새 species 발견
- NPC 최초 대화
- 퀘스트 시작/완료
- 보스 발견/처치

### Quest

초기에는 복잡한 대화 시스템 없이 데이터 기반 상태 머신으로 만든다.

Quest state:

- locked
- available
- active
- readyToComplete
- completed

Quest objective examples:

- discoverRegion
- meetNpc
- eatSpeciesCount
- defeatBoss
- reachPoint

### Ability Gate

새 지역은 단순 레벨 제한보다 species ability로 접근하게 한다.

Examples:

- waterfall requires climb
- cave requires crawl or squeeze
- surface gap requires glide
- deep current requires dive

## 신규 로드맵

### M8.5 — Master Spec 전환

목표: 새 기획을 문서 기준선으로 확정하고 기존 시스템의 의미를 재분류한다.

- [x] `MASTER_SPEC.md` 추가
- [x] 기존 성장 명세를 legacy prototype spec으로 표시
- [x] 로드맵을 탐험 중심으로 재배치
- [x] 핵심 결정 기록 추가
- [x] README의 프로젝트 설명 갱신

완료 조건: 앞으로의 작업 기준이 `Explore -> Discover -> Unlock -> Explore Again`으로 고정된다.

### M9 — Region and Discovery Foundation

목표: 단일 사각 필드를 첫 탐험 지역으로 재구성한다.

- Region 데이터 모델
- 현재 Ocean shallows region 정의
- 카메라/월드에 region id 연결
- discovery event bus
- 지역 발견률 HUD 최소 표시
- 도감에 Region 탭 추가
- 저장 schema에 discovered regions 추가

완료 조건: 플레이어가 지역을 발견하고 지역 발견률이 저장/복원된다.

### M10 — Quest Foundation

목표: 종 해금을 포식 반복이 아닌 quest reward로 전환할 기반을 만든다.

- Quest 데이터 모델
- Quest state machine
- 간단한 NPC marker
- NPC 대화 오버레이
- Exploration quest 1개
- Collection quest 1개
- quest reward로 species unlock 지원

완료 조건: 퀘스트 완료로 새 종이 해금된다.

### M11 — Species Ability Prototype

목표: 종별 고유 능력 하나 이상이 실제 탐험 경로를 바꾼다.

- Species ability field 추가
- ability gate component 추가
- 첫 능력 2개 구현
- 능력별 이동 감각 차이 적용
- 종변화 UI에 ability 설명 표시

완료 조건: 특정 종으로만 접근 가능한 지역 또는 오브젝트가 생긴다.

### M12 — Region Gate and Mini Boss

목표: 보스가 다음 지역을 여는 관문 역할을 한다.

- Boss entity foundation
- boss arena boundary
- boss defeat event
- next region unlock
- respawn penalty 최소화

완료 조건: 첫 boss를 통해 새 지역 접근이 열린다.

### M13 — Adventure Alpha Polish

목표: Web alpha에서 탐험 어드벤처로 보이는 첫 수직 절편을 완성한다.

- 첫 지역 발견률 100%
- NPC 1명
- Quest 2~3개
- Species 2개 이상 고유 능력
- 새 지역 1개 잠금/해금
- 도감 Region/Species/Quest 통합
- 세로 모바일 UI 정리

완료 조건: 10분 플레이에서 `Explore -> Discover -> Unlock -> Explore Again`이 체감된다.

## 출시 계획 영향

기존 M9의 양대 마켓 출시 준비는 보류한다.

이유:

- 현재 게임은 기술 프로토타입으로는 충분하지만 새 Master Spec의 핵심인 탐험, 퀘스트, 지역 해금이 아직 없다.
- 지금 마켓 준비를 시작하면 앱 이름, 스토어 문구, 스크린샷, 개인정보 선언이 곧 다시 바뀔 가능성이 높다.

새 기준:

- Web alpha는 계속 배포한다.
- Android/iOS 실기기 검증은 계속 유지한다.
- Google Play 내부 테스트와 TestFlight는 M13 이후로 이동한다.
