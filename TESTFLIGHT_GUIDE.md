# TestFlight 등록 가이드

## 1단계: 앱 아이콘 설정

### 1.1 아이콘 다운로드
1. 브라우저에서 열린 `app_icon_generator.html`에서 **Download Icon** 버튼 클릭
2. `komjirak-app-icon-1024.png` 파일 다운로드

### 1.2 모든 사이즈 생성
1. https://www.appicon.co/ 접속
2. 다운로드한 `komjirak-app-icon-1024.png` 업로드
3. **iOS** 체크하고 Generate 클릭
4. `AppIcon.zip` 다운로드 후 압축 해제

### 1.3 Xcode에 아이콘 적용
```bash
# iOS 폴더의 기존 아이콘 백업
mv ios/Runner/Assets.xcassets/AppIcon.appiconset ios/Runner/Assets.xcassets/AppIcon.appiconset.backup

# appicon.co에서 생성된 AppIcon.appiconset 폴더를 복사
# (다운로드한 폴더의 Assets.xcassets/AppIcon.appiconset)
cp -r ~/Downloads/Assets.xcassets/AppIcon.appiconset ios/Runner/Assets.xcassets/
```

또는 Xcode에서:
1. `ios/Runner.xcworkspace` 열기
2. 왼쪽 네비게이터에서 `Assets.xcassets` 클릭
3. `AppIcon` 선택
4. appicon.co에서 생성된 이미지들을 드래그 앤 드롭

---

## 2단계: Apple Developer 계정 설정

### 2.1 Apple Developer Program 가입
- https://developer.apple.com/programs/
- $99/년 (필수)

### 2.2 App Store Connect 접속
- https://appstoreconnect.apple.com/

### 2.3 새 앱 등록
1. **My Apps** > **+** > **New App**
2. 정보 입력:
   - **Platform**: iOS
   - **Name**: Komjirak Frame
   - **Primary Language**: Korean
   - **Bundle ID**: 새로 생성 (예: `com.komjirak.frame`)
   - **SKU**: `komjirak-frame` (임의의 고유 ID)
   - **User Access**: Full Access

---

## 3단계: Xcode 프로젝트 설정

### 3.1 Bundle Identifier 변경
```bash
# Xcode에서
open ios/Runner.xcworkspace
```

**Xcode에서 설정:**
1. Runner 프로젝트 선택
2. **TARGETS > Runner** 선택
3. **Signing & Capabilities** 탭
   - **Team**: 본인의 Apple Developer Team 선택
   - **Bundle Identifier**: `com.komjirak.frame` (App Store Connect에서 설정한 것과 동일)
4. **Automatically manage signing** 체크

### 3.2 앱 정보 설정 (선택사항)
`ios/Runner/Info.plist`에서:
```xml
<key>CFBundleDisplayName</key>
<string>Komjirak</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

---

## 4단계: 빌드 및 업로드

### 4.1 Archive 빌드
```bash
# Flutter 프로젝트 루트에서
flutter build ipa --release
```

빌드가 완료되면:
- 생성 위치: `build/ios/archive/Runner.xcarchive`

### 4.2 Xcode에서 업로드
```bash
# Xcode 열기
open ios/Runner.xcworkspace
```

**Xcode에서:**
1. 상단 메뉴: **Product > Archive**
2. Archive가 완료되면 Organizer 창이 자동으로 열림
3. **Distribute App** 클릭
4. **App Store Connect** 선택
5. **Upload** 선택
6. 다음 화면에서 계속 **Next**
7. **Upload** 클릭

⏱️ 업로드 완료까지 5-10분 소요

---

## 5단계: TestFlight 설정

### 5.1 App Store Connect에서 설정
1. https://appstoreconnect.apple.com/ 접속
2. **My Apps > Komjirak Frame** 선택
3. **TestFlight** 탭 클릭
4. 업로드한 빌드가 **Processing** 상태로 표시됨 (10-30분 소요)

### 5.2 테스터 추가

#### 내부 테스터 (간단, 빠름)
1. **Internal Testing** 그룹 생성
2. **Add Internal Testers** 클릭
3. 이메일 추가 (본인 또는 팀원)
4. 빌드 선택 후 **Save**

#### 외부 테스터 (심사 필요, 최대 10,000명)
1. **External Testing** 그룹 생성
2. **Add External Testers** 클릭
3. 이메일 추가
4. **Submit for Review** (약 1-2일 소요)

### 5.3 테스트 정보 입력
- **What to Test**: 테스트할 기능 설명
- **App Description**: 앱 간단 설명
- **Feedback Email**: 피드백 받을 이메일
- **Privacy Policy URL** (선택사항)

---

## 6단계: 테스터에게 배포

### 6.1 초대 메일 발송
- 테스터의 이메일로 TestFlight 초대 메일 자동 발송됨

### 6.2 테스터가 할 일
1. iPhone에서 **TestFlight** 앱 다운로드 (App Store)
2. 초대 메일의 **View in TestFlight** 링크 클릭
3. TestFlight 앱에서 **Accept** 후 **Install**

### 6.3 Public Link로 배포 (외부 테스터만 가능)
1. App Store Connect > TestFlight > External Testing
2. 그룹 선택 > **Public Link** 활성화
3. 링크 복사하여 배포

---

## 버전 업데이트 시

```bash
# 1. pubspec.yaml에서 버전 업데이트
# version: 1.0.0+1 → 1.0.1+2

# 2. 빌드 및 업로드
flutter build ipa --release

# 3. Xcode에서 Archive & Upload (위와 동일)
```

---

## 트러블슈팅

### 빌드 실패 시
```bash
# 클린 빌드
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter build ipa --release
```

### Archive 메뉴가 비활성화된 경우
- Xcode 상단에서 **Any iOS Device (arm64)** 선택 후 Archive

### 업로드 실패 시
- Xcode > Preferences > Accounts에서 Apple ID 재로그인
- 인증서 및 프로비저닝 프로파일 확인

---

## 유용한 링크

- **App Store Connect**: https://appstoreconnect.apple.com/
- **TestFlight 가이드**: https://developer.apple.com/testflight/
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/

---

## 체크리스트

- [ ] 앱 아이콘 생성 및 적용
- [ ] Apple Developer Program 가입 ($99)
- [ ] App Store Connect에서 새 앱 등록
- [ ] Bundle ID 설정 및 Signing 설정
- [ ] `flutter build ipa` 성공
- [ ] Xcode Archive & Upload 성공
- [ ] TestFlight에서 빌드 Processing 완료
- [ ] 테스터 추가
- [ ] TestFlight 앱에서 설치 테스트
