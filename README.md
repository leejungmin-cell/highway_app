# Highway Toll Calculator

고속도로 통행료 할인 시간 계산을 위한 Flutter 앱

## Overview
입차/출차 시간을 기준으로 심야 할인 적용 여부를 계산해주는 앱입니다.  
복잡한 할인 규칙을 직관적인 UI로 단순화했습니다.

## Features
- 입차 / 출차 시간 선택 UI
- 심야 할인 자동 계산 (23:00 ~ 05:00 기준)
- 할인 조건 안내 및 결과 표시
- HTML 기반 UI → Flutter로 변환 구현

## Tech Stack
- Flutter
- Dart

## Preview
![app](assets/screenshot.png)

## Key Point
- HTML UI를 Flutter 위젯 구조로 변환
- 사용자 입력 흐름 중심 UI 설계
- 시간 선택 → 계산 → 결과 구조 최적화

## Run
```bash
flutter pub get
flutter run
