# Web Alpha 배포

## 공개 주소

- 저장소: `https://github.com/roycekim84/fish-growth-rpg`
- Web alpha: `https://roycekim84.github.io/fish-growth-rpg/`

## 자동 배포

`.github/workflows/deploy-web.yml`이 `main` push마다 다음 품질 게이트를 실행한다.

1. Flutter 3.44.0 설치
2. `flutter pub get`
3. `flutter analyze`
4. `flutter test`
5. `/fish-growth-rpg/` base href로 Web release build
6. GitHub Pages artifact 업로드 및 배포

Pages 단계는 Node 24 기반 공식 액션 `configure-pages@v6`, `upload-pages-artifact@v5`, `deploy-pages@v5`를 사용한다.

분석, 테스트 또는 빌드가 실패하면 기존 공개 버전을 유지하고 새 버전을 배포하지 않는다.

## 수동 배포

GitHub 저장소의 Actions 탭에서 `Deploy Flutter Web Alpha` 워크플로를 선택하고 `Run workflow`를 실행한다.

## 로컬 배포 빌드 검증

```text
flutter build web --release --base-href "/fish-growth-rpg/"
```

로컬 루트(`/`)에서 테스트할 때와 GitHub Pages 하위 경로에서 테스트할 때 base href가 다르므로 배포 전용 명령을 사용한다.

## 장애 대응

- Actions의 build job에서 분석, 테스트, 의존성 또는 Web 컴파일 오류를 확인한다.
- deploy job 실패 시 저장소 Settings → Pages의 Source가 GitHub Actions인지 확인한다.
- 빈 화면이나 404가 발생하면 base href와 저장소 이름이 일치하는지 확인한다.
- 긴급 롤백은 정상 동작하던 커밋을 되돌리는 새 커밋을 `main`에 반영한다.
