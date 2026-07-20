# Fish Adventure RPG — Master Spec

Version: 1.0

## Project Vision

플레이어는 한 마리의 물고기가 되어 넓은 수중 세계를 탐험한다.

이 게임의 목표는 단순히 강한 물고기가 되는 것이 아니라 새로운 종을 만나고, 새로운 능력을 얻고, 새로운 지역을 탐험하는 것이다.

핵심 경험은 다음 순환이다.

```text
Explore -> Discover -> Unlock -> Explore Again
```

## Genre and Platform

- Genre: 2D Adventure RPG
- Main platforms: iOS, Android
- Test platform: Web alpha
- Engine: Flutter + Flame
- Screen: portrait mobile first
- Art direction: 2D pixel art, warm color, clean silhouettes, smooth animation

## Core Design Philosophy

### Exploration First

탐험이 게임의 중심이다. 전투, 레벨, 사냥, 수집은 탐험을 돕는 시스템이다.

### Discovery Is Reward

새로운 지역, 물고기, NPC, 퀘스트, 능력 자체가 보상이다.

### Species Over Stats

종은 상위호환이 아니다. 각 종은 새로운 이동 방식, 새로운 능력, 새로운 플레이 스타일을 제공한다.

### Respect Player Time

무의미한 반복 노가다는 만들지 않는다. 플레이 시간이 길어질수록 새로운 경험이 계속 제공되어야 한다.

## Core Gameplay Loop

```text
Explore
  -> Find Fish / NPC / Region Clue
  -> Complete Quest or Encounter
  -> Unlock Species or Ability
  -> Reach New Area
  -> Clear Boss or Gate
  -> Explore Again
```

## Player

플레이어는 현재 선택한 물고기 종을 조작한다.

Player state:

- HP
- Hunger
- Stamina
- Experience
- Level

Level은 유지되고 Species가 바뀐다. Level은 탐험 안정성을 올리는 세로 성장이고, Species는 지역 접근과 플레이 방식을 바꾸는 가로 성장이다.

## Progression

Vertical progression:

- Level

Horizontal progression:

- Species
- Encyclopedia
- Quest
- Exploration
- Region access

## Species System

Species는 핵심 시스템이다. 해금 기준은 장기적으로 포식 횟수보다 탐험, 퀘스트, 보스, 지역 발견을 우선한다.

Examples:

- Salmon: waterfall climb
- Flying Fish: glide
- Octopus: cave exploration
- Electric Eel: electric ability
- Shark: combat specialist

각 Species는 고유 능력을 가진다. 스탯 배율은 보조 수단이며, 상위호환 구조를 만들지 않는다.

## Movement

Base movement:

- Swim

Unlockable movement:

- Fast swim
- Dash
- Climb
- Glide
- Crawl
- Dive
- Jump

Species마다 이동 방식과 접근 가능한 지형이 달라진다.

## Combat

전투는 탐험을 위한 수단이다.

- 작은 물고기는 사냥 가능한 자원이다.
- 큰 물고기는 위험 요소이다.
- 보스는 특정 지역의 관문이다.

전투가 장기 반복 목표를 독점하지 않도록 한다.

## Hunger

Hunger는 플레이를 귀찮게 만드는 시스템이 아니다.

- 이동하면 감소한다.
- 먹으면 회복한다.
- 부족하면 회복 불가 또는 이동 효율 저하가 발생한다.
- 탐험 리듬을 만드는 압력으로만 사용한다.

## HP

HP 감소 원인:

- 적
- 환경
- 보스

HP가 0이 되면 respawn한다. 패널티는 최소화한다.

## Regions

세계는 여러 지역으로 나뉜다.

Initial examples:

- River
- Lake
- Ocean
- Deep Sea
- Coral Reef
- Cave
- Arctic
- Volcano
- Hidden Area

각 지역은 발견률을 가진다. 100%가 되면 Complete로 표시한다.

## Encyclopedia

도감은 장기 목표이다.

기록 대상:

- 만난 물고기
- 획득 아이템
- 발견 지역
- NPC

## Quest

Quest는 새로운 Species를 해금하는 주요 수단이다.

Quest types:

- Main
- Side
- Daily
- Collection
- Exploration

초기 구현에서는 Main, Exploration, Collection부터 시작한다. Daily는 서버나 날짜 설계가 필요하므로 후순위로 둔다.

## NPC

NPC는 다음 역할을 담당한다.

- 정보 제공
- 퀘스트
- 상점
- 스토리

초기 구현에서는 정보 제공과 퀘스트 제공만 포함한다.

## Boss

각 주요 지역에는 Boss가 존재한다. Boss를 처치하면 새 지역 또는 새 능력이 열린다.

## Save

저장 항목:

- Level
- Species
- Quest
- Inventory
- Region
- Encyclopedia
- Achievements
- GPS
- Photo stamp
- Settings

현재 프로토타입의 save schema는 레벨, 경험치, HP, 포만감, 현재 종, 종 해금, 도감 발견, 포식 카운트를 저장한다. 이후 schema migration으로 Quest, Region, Achievement를 추가한다.

## GPS and Photo

GPS와 사진 시스템은 현실 탐험을 게임으로 연결하는 선택 기능이다.

가능한 기능:

- 지역 인증
- 방문 기록
- 탐험 업적
- 실제 위치 기반 이벤트
- 사진 GPS 기반 도감/업적 연동

이 기능은 강제하지 않으며, 핵심 탐험 루프가 안정화된 뒤 별도 마일스톤에서 검증한다.

## Design Rules

새 기능을 만들기 전에 반드시 확인한다.

1. 탐험을 더 재미있게 만드는가?
2. 새로운 플레이를 만드는가?
3. 플레이 시간을 낭비하지 않는가?
4. 기존 시스템과 충돌하지 않는가?

답이 명확히 YES가 아니면 만들지 않는다.

## Golden Rule

이 게임은 물고기를 키우는 게임이 아니다.

세상을 탐험하는 게임이다.

플레이어가 "저 너머에는 뭐가 있을까?"라는 궁금증을 계속 느끼게 만드는 것이 프로젝트의 가장 중요한 목표이다.
