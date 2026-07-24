# 개발 로드맵

## 운영 방식

- 한 번에 하나의 마일스톤만 `진행 중`으로 둔다.
- 각 마일스톤은 플레이 가능한 결과와 검증 명령을 가져야 한다.
- 기능, 임시 에셋, 밸런스 변경을 가능한 한 분리해 커밋한다.
- 범위 변경은 `PROJECT_SPEC.md`와 `DECISIONS.md`에 먼저 반영한다.
- 각 작업 종료 시 `WORK_LOG.md`를 갱신한다.

## M0 — 기획 및 기반 확정 `완료`

목표: 기술, 아트, 범위와 작업 방식을 문서로 고정한다.

- [x] 핵심 게임 명세 작성
- [x] Flutter + Flame 확정
- [x] Android/iOS 출시, Web 테스트 정책 확정
- [x] 픽셀아트 에셋 계획 작성
- [x] 기술 구현 계획 작성
- [x] 단계별 로드맵 작성
- [x] Git 저장소 초기화 및 문서 기준선 커밋
- [x] 앱 이름, package/bundle ID 임시값 결정

완료 조건: 문서 기준선이 커밋되고 프로젝트 생성에 필요한 식별자가 결정됨.

## M1 — 실행 가능한 세로형 게임 셸 `완료`

목표: Web, Android, iOS에서 같은 프로젝트가 실행된다.

- [x] Flutter 프로젝트 생성
- [x] Flame 설치 및 버전 고정
- [x] portrait orientation 적용
- [x] `FishGame`, `World`, `CameraComponent`, `GameWidget` 구성
- [x] Flutter 오버레이 샘플 HUD
- [x] 개발용 논리 해상도와 픽셀 렌더링 검증 화면
- [x] 종 데이터 JSON 3종 로드
- [x] 로컬 품질 명령 검증

완료 조건:

- `flutter analyze` 통과
- `flutter test` 통과
- `flutter build web` 통과
- Android/iOS 최소 1개 환경에서 실행 확인

검증 결과:

- `flutter analyze`: 통과
- `flutter test`: 2개 테스트 통과
- `flutter build web --release`: 통과
- `flutter build apk --debug`: 통과
- iOS simulator build: 로컬 CoreSimulator 버전 불일치와 서명 대상 메타데이터 문제로 보류

## M2 — 이동, 카메라, 필드 `완료`

목표: 플레이어가 물속 느낌으로 필드를 이동한다.

- [x] 임시 플레이어 픽셀 스프라이트
- [x] 드래그 입력과 방향 표시
- [x] 가속, 관성, 감속
- [x] 부드러운 방향 전환 및 좌우 flip
- [x] 누르고 있는 동안 작동하는 부스터 버튼
- [x] 필드 경계와 바깥 방향 속도 제거
- [x] 플레이어 추적 카메라
- [x] 배경 타일, 수중 빛 레이어, 움직이는 거품

완료 조건: 모바일 터치와 웹 마우스 모두 이동 가능하며 경계와 카메라가 안정적임.

검증 결과:

- 이동 물리, 관성, 부스터, 데드존, 필드 경계 테스트 통과
- Flutter HUD 부스터 입력 테스트 통과
- 390×844 웹 화면 렌더링 및 마우스 드래그 확인
- 브라우저 런타임 warning/error 없음
- `flutter analyze`, 전체 테스트 7개 통과
- Web release 및 Android debug APK 빌드 통과

## M3 — NPC, AI, 스폰 `완료`

목표: 3종 NPC가 살아 움직이는 단일 생태 필드를 만든다.

- [x] SmallFish, PufferFish, HunterFish 데이터 기반 개체
- [x] Wander/Flee/Chase 상태 머신
- [x] 종별 공격 성향 차이
- [x] 감지 범위와 경계 회피
- [x] 종별 최대 개체 수 30/10/5
- [x] 플레이어 및 NPC 안전 스폰 거리
- [x] 제거된 개체의 주기적 재생성
- [x] 거리에 따른 AI 판단 주기 조정

완료 조건: 종별 행동 차이가 보이고 개체 수가 장시간 안정적으로 유지됨.

검증 결과:

- NPC 상태 전환, 경계 회피, 안전 스폰 테스트 통과
- 전체 자동 테스트 14개 통과
- 390×844 웹 화면에서 NPC 45/45 및 실제 추격·도망 확인
- 웹 런타임 warning/error 없음
- Web release 및 Android debug APK 빌드 통과

## M4 — 포식과 전투 `완료`

목표: 먹이, 호각, 위험 대상의 판단과 결과가 명확하다.

- [x] 충돌 영역
- [x] 1.15/0.9 크기 규칙
- [x] 물기 피해와 개체 쌍 쿨다운
- [x] NPC HP와 사망 상태
- [x] 중복 보상 방지
- [x] 위험도 링과 타격/포식 피드백
- [x] 플레이어 사망 및 재시작

완료 조건: 세 가지 위험 관계가 색상+아이콘+행동 결과로 구분되고 자동 테스트가 통과함.

검증 결과:

- 크기 판정 경계값과 실제 Flame 충돌·포식·재스폰 통합 테스트 통과
- 전체 자동 테스트 19개 및 `flutter analyze` 통과
- 390×844 웹 화면에서 HP HUD, 위험도 링, NPC 45/45 확인
- 웹 런타임 warning/error 없음
- Web release 및 Android debug APK 빌드 통과

## M4.5 — 반자동 사냥 실험 `완료`

목표: 반복적인 약한 먹이 추적을 줄이면서 수동 사냥과 위험 회피의 가치를 유지한다.

- [x] 자동사냥 ON/OFF 버튼
- [x] 가장 가까운 초록 대상만 자동 선택
- [x] 수동 기본 속도의 75%로 자동 추적
- [x] 빨간 위험 대상 접근 시 자동 중단
- [x] HP 35% 이하에서 자동 중단
- [x] 수동 드래그 입력 시 즉시 해제
- [x] 자동 부스터, 자동 회복, 자동 종변화 금지
- [x] Web alpha에서 추적과 안전 중단 감각 확인

완료 조건: 자동사냥이 편의 기능으로 작동하고 수동 플레이보다 높은 생존율이나 사냥 효율을 제공하지 않음.

검증 결과:

- 최근접 초록 대상, 위험 반경, 저체력, 75% 속도와 수동 우선권 테스트 통과
- 전체 자동 테스트 25개 및 `flutter analyze` 통과
- 390×844 웹 화면에서 `AUTO ON / HUNT` 추적과 안전 중단 확인
- 웹 런타임 warning/error 없음
- Web release 및 Android debug APK 빌드 통과

## M5 — 생존과 성장 `완료`

목표: 먹고, 쉬고, 성장하는 루프를 완성한다.

- [x] HP/Fullness/EXP HUD
- [x] 먹기 보상
- [x] 1.5초 정지 회복
- [x] 전투 후 1초 회복 금지
- [x] 레벨업과 스탯 증가
- [x] 레벨업 및 회복 이펙트
- [x] 기본 밸런스 패스

완료 조건: HP가 낮을 때 먹이를 확보하고 안전지대에서 회복하는 흐름이 자연스러움.

검증 결과:

- 다중 레벨업, Fullness 상한, 종별 카운트와 실제 포식 보상 테스트 통과
- 정지·관성·수동 입력·전투 지연·비례 회복 테스트 통과
- 전체 자동 테스트 31개 및 `flutter analyze` 통과
- 390×844 웹에서 실제 수치 HUD, 피해와 부활 상태 갱신 확인
- 웹 런타임 warning/error 없음
- Web release 및 Android debug APK 빌드 통과
- 초기 Hunter 주변에서 정지 시 압박이 강한 점은 M6 병행 밸런스 관찰 항목으로 유지

## M6 — 종 수집과 종변화 `완료`

목표: 100마리 포식 장기 목표와 플레이 변화가 동작한다.

- [x] 종별 포식 카운트
- [x] 100마리 해금 이벤트
- [x] 도감 Flutter 오버레이
- [x] 종변화 Flutter 오버레이
- [x] 전투 중 변경 제한
- [x] 종별 외형과 스탯 배율
- [x] HP 비율 유지
- [x] 종변화 연출

개발 편의를 위해 debug 빌드에는 포식 횟수 설정 기능을 제공할 수 있다.

완료 조건: 실제 100회 및 경계값 자동 테스트에서 해금되고 두 종 이상의 플레이 차이가 체감됨.

검증 결과:

- 99/100 경계, 중복 해금 방지, 잠금 종 변경 거부 테스트 통과
- 종별 MaxHP/STR/SPD/Size/Weight 배율과 HP 비율 유지 테스트 통과
- 실제 Flame 월드의 종변화 성공 및 전투 직후 제한 통합 테스트 통과
- 도감·종변화 Flutter 오버레이 위젯 테스트를 포함해 전체 자동 테스트 36개 통과
- 390×844 웹에서 도감, 종 선택, 미해금 상태와 일시 정지 화면 확인
- `flutter analyze`, Web release 및 Android debug APK 빌드 통과

## M7 — 저장, 복원, 안정화 `완료`

목표: 앱을 닫고 다시 열어도 핵심 진행도가 안전하게 보존된다.

- [x] 저장 라이브러리 확정
- [x] schema version 1
- [x] 자동 저장 및 앱 수명주기 저장
- [x] 손상/누락 데이터 복구
- [x] UTC 마지막 저장 시간
- [x] Web/Android 저장 확인 및 iOS 공통 구현 연결
- [x] 반복 직렬화·복원 및 게임 통합 안정성 테스트

완료 조건: 재실행, 백그라운드 복귀, 업데이트 모의 테스트에서 진행도가 보존됨.

검증 결과:

- Flutter 공식 `shared_preferences` 2.5.5와 비캐시 `SharedPreferencesAsync` 적용
- schema v1 JSON 왕복, 손상 데이터 제거, 미래 schema 보존 테스트 통과
- 레벨·EXP·HP·Fullness·현재 종·해금·발견·포식 카운트·UTC 시간 복원 통과
- 중요 상태 변경 700ms 디바운스와 inactive/paused/detached 즉시 저장 구현
- 전체 자동 테스트 41개 및 `flutter analyze` 통과
- Web release와 Android debug APK 빌드 통과
- 390×844 Web에서 SAVE 상태와 UI 오버플로 없음, 런타임 오류 없음
- Android API 36에서 HP 26 저장 후 프로세스 종료·재실행 시 HP 26 복원 확인
- iOS 런타임 검증은 기존 로컬 Xcode/CoreSimulator 환경 블로커로 M9 실기기 회귀 항목에 유지

## M8 — 픽셀아트 완성 및 폴리시

목표: 임시 도형을 일관된 픽셀아트와 자연스러운 연출로 교체한다.

- [x] 시작 종과 NPC 3종 모델 시트·팔레트·4프레임 swim 스트립
- [x] 플레이어·NPC 런타임 애니메이션과 좌우 반전 연결
- [x] 반복 해저 배경 타일, 8종 props 아틀라스, 픽셀 거품·부유물
- [x] HUD·도감·종변화 공통 픽셀 UI 스킨과 실제 종 초상화
- [x] bite/hit/포식/레벨업/해금 픽셀 파티클
- [x] 사운드와 햅틱 최소 세트
- [x] 색각 접근성 보조 표시
- [x] 기기별 크기와 성능 조정

완료 조건: 모든 화면과 게임 에셋이 아트 규칙을 따르고 임시 에셋이 남지 않음.

구현 감사: runtime 임시 도형·이미지는 남아 있지 않으며 320×568과 430×932 세로 화면 회귀 테스트를 통과했다. 프로젝트 원칙에 따라 M8 최종 완료 표시는 모바일 실기기 승인 후 적용한다.

## Post-M13 — 양대 마켓 출시 준비

상태: 보류. Master Spec 전환으로 인해 M13 이후 다시 착수한다.

목표: 비공개/내부 테스트 트랙에 제출 가능한 빌드를 만든다.

- 앱 ID, 버전, 서명과 환경 분리
- Android App Bundle
- iOS archive/TestFlight
- 아이콘, 스플래시, 스토어 스크린샷
- 개인정보 및 데이터 수집 선언 검토
- 크래시 없는 기본 플레이 세션
- 실기기 회귀 테스트

완료 조건: Google Play 내부 테스트와 TestFlight에 설치 가능한 후보 빌드가 생성됨.

## 현재 다음 작업

1. M8.5 Master Spec 전환 문서 기준선 확정
2. M9 Region and Discovery Foundation 착수
3. Android/iOS 실기기 검증은 계속 유지하되 마켓 출시 준비는 탐험 수직 절편 이후로 이동

## M8.5 — Master Spec 전환

목표: 기존 성장/사냥 프로토타입을 탐험 어드벤처 RPG 기준으로 재정렬한다.

- [x] `docs/MASTER_SPEC.md` 추가
- [x] `docs/PIVOT_PLAN.md` 추가
- [x] 기존 `PROJECT_SPEC.md`를 legacy prototype spec으로 표시
- [x] README의 프로젝트 설명 갱신
- [x] 결정 기록에 제품 방향 전환과 종 해금 정책 추가
- [x] 다음 구현 마일스톤 착수 전 사용자 승인

완료 조건: 앞으로의 작업 기준이 `Explore -> Discover -> Unlock -> Explore Again`으로 고정된다.

## M9 — Region and Discovery Foundation

목표: 단일 사각 필드를 첫 탐험 지역으로 재구성한다.

- [x] Region 데이터 모델
- [x] 현재 Ocean shallows region 정의
- [x] 카메라/월드에 region id 연결
- [x] discovery event bus
- [x] 지역 발견률 HUD 최소 표시
- [x] 도감에 Region 탭 추가
- [x] 저장 schema v2에 discovered regions/landmarks 추가 및 v1 migration

완료 조건: 플레이어가 지역을 발견하고 지역 발견률이 저장/복원된다.

## M10 — Quest Foundation

목표: 종 해금을 포식 반복이 아닌 quest reward로 전환할 기반을 만든다.

- [x] Quest 데이터 모델
- [x] Quest state machine
- [x] 간단한 NPC marker
- [x] NPC 대화 오버레이
- [x] Exploration quest 1개
- [x] Collection quest 1개
- [x] quest reward로 species unlock 지원

완료 조건: 퀘스트 완료로 새 종이 해금된다.

## M11 — Species Ability Prototype

목표: 종별 고유 능력 하나 이상이 실제 탐험 경로를 바꾼다.

- [x] Species ability field 추가
- [x] ability gate component 추가
- [x] 첫 능력 2개 구현
- [x] 능력별 이동 감각 차이 적용
- [x] 종변화 UI에 ability 설명 표시

완료 조건: 특정 종으로만 접근 가능한 지역 또는 오브젝트가 생긴다.

## M12 — Region Gate and Mini Boss

목표: 보스가 다음 지역을 여는 관문 역할을 한다.

- [x] Boss entity foundation
- [x] boss arena boundary
- [x] boss defeat event
- [x] next region unlock
- [x] respawn penalty 최소화

완료 조건: 첫 boss를 통해 새 지역 접근이 열린다.

## M13 — Adventure Alpha Polish

목표: Web alpha에서 탐험 어드벤처로 보이는 첫 수직 절편을 완성한다.

- [x] 첫 지역 발견률 100% 달성 가능 구조
- [x] NPC 1명
- [x] Quest 3개
- [x] Species 2개 이상 고유 능력
- [x] 새 지역 1개 잠금/해금 및 실제 전환
- [x] 도감 Region/Species/Quest 통합
- [x] 세로 모바일 UI에 탐험 상태 정리

완료 조건: 10분 플레이에서 `Explore -> Discover -> Unlock -> Explore Again`이 체감된다.
