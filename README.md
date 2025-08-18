<p align="center">
  <img src="https://github.com/user-attachments/assets/e201436f-fdf4-4460-9703-7c47e79757da" width="200" height="200"/>
</p>

<br>

# 우리들의 다이어리, "울다"

![Frame 7](https://github.com/user-attachments/assets/6ae1cdc2-5986-4ddc-9de7-0cdd1b6b7972)

<br>

### AI 답장 받는 일기 애플리케이션

> 우리들의 일기 다이어리 "울다"는 하루를 특별하게 기록하는 일기 애플리케이션입니다.<br>
> ChatGPT와 연동하여 사용자가 입력한 일기 내용에 따라 따뜻한 위로와 공감의 답장을 받을 수 있습니다.<br>
> 힐링이 필요한 하루를 울다와 함께 채워보세요.

<br>

| ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 17 34](https://github.com/user-attachments/assets/2fea2d5a-db4b-4331-855a-028a02a75a37) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 19 18](https://github.com/user-attachments/assets/33c3789e-7484-4200-8d05-4c519321aea3) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 44 23](https://github.com/user-attachments/assets/d7297155-44a8-4263-9717-6beef2a6d6b6) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 45 46](https://github.com/user-attachments/assets/9414cc03-8047-4969-ba6e-8c9150917659) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 46 22](https://github.com/user-attachments/assets/e4f72b02-43ff-45a0-839e-cf227403b643) |
|-|-|-|-|-|

<br>

## Clone & Build

<img src="https://github.com/user-attachments/assets/5688e672-52a9-4180-9ce7-5e8ef6e29cd4" width=240>

<br>

<img src="https://github.com/user-attachments/assets/2356e23f-f6cd-4d41-b34a-88b7f0bda549" width=500>

<br>
<br>

API Key 때문에 실제 AI 응답을 받는 기능은 제한되어 있습니다.<br>
Clone 후 GloomyDiaryExample 스킴을 빌드하여 제한된 기능으로 시뮬레이션이 가능합니다.<br>

<br>

<img width="275" height="341" alt="스크린샷 2025-08-18 오후 2 27 19" src="https://github.com/user-attachments/assets/fa28f93c-89f0-4f8f-912d-06cf045dab09" />

(예시 이미지 입니다.)

빌드 시 Macro “ComposableArchitectureMacros” from package ..." 와 같은 메시지가 뜬다면<br>
모두 "Trust and Enable" 처리 후 빌드 해주세요.

<br>

<br>

## 프로젝트 정보

<br>

|개발 기간|인원|Xcode|앱스토어|
|-|-|-|-|
|2024.07 ~ 진행 중|1인|16.2|[<img src="https://github.com/user-attachments/assets/dba5b62c-9db7-4715-b4cc-2b817503b082" height="50">](https://apps.apple.com/us/app/%EC%9A%B8%EB%8B%A4-%EC%9A%B0%EB%A6%AC%EB%93%A4%EC%9D%98-%EC%9D%BC%EA%B8%B0-%EB%8B%A4%EC%9D%B4%EC%96%B4%EB%A6%AC/id6738892165)|


<br>

##  

### 기술 스택
Swift, UIKit, TCA, Swift-Dependencies<br>
SwiftData, UserDefaults, OpenAI<br>
SnapKit, Lottie, Firebase, Amplitude<br>

<br>

### 구조
```mermaid
%%{init: {"theme": "base", "themeVariables": {"fontSize": "12px", "nodeSpacing": "5"}}}%%

flowchart TD
    subgraph Presentation
    subgraph ViewController
    View -- send --> Action
    subgraph Store
    Action --> Reducer
    Reducer --> State
    Action --> Effect
    Effect --> Action
    end
    State -.-> View
    end
    end
    style Presentation fill:#bcd

    subgraph Dependencies
    
    CounselingSessionRepository
    UserSettingRepository
    AIService
    Logger
    end

    Presentation-->Dependencies
    style Dependencies fill:#bcd
```

<br>

### 구현사항
📌 제네릭 뷰를 갖는 BaseViewController를 통해 뷰와 뷰 컨트롤러 코드 분리<br>
📌 TCA 구조 및 Swift-Dependencies를 통한 의존성 관리<br>
📌 애니메이션 옵션을 지정하여 Swift Concurrency 형태로 실행할 수 있는 커스텀 Animation / AnimationGroup 구현<br>
📌 커스텀 애니메이션 및 탭바가 적용된 CircularTabBarController 구현 (로그 제거 예정)<br>
📌 커스텀 이미지 캐시 구현<br>
📌 VersionedSchema를 통한 마이그레이션<br>

<br>

### 핵심 경험 & 트러블슈팅
[[UICollectionView Scroll Hitch 최적화 및 이미지 처리 개선]](https://github.com/LURKS02/GloomyDiary/wiki/%08UICollectionView-Scroll-Hitch-%EC%B5%9C%EC%A0%81%ED%99%94-%EB%B0%8F-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%B2%98%EB%A6%AC-%EA%B0%9C%EC%84%A0)<br>
[[UIViewControllerAnimatedTransitioning 관련 이슈]](https://github.com/LURKS02/GloomyDiary/wiki/UIViewControllerAnimatedTransitioning-%EA%B4%80%EB%A0%A8-%EC%9D%B4%EC%8A%88)<br>
[[TCA 사용기]](https://github.com/LURKS02/GloomyDiary/wiki/TCA-%EC%82%AC%EC%9A%A9%EA%B8%B0)

<br>

---

##### 이슈 네이밍 :  [FEATURE / FIX / REFACTOR / DOCS] 작업 내용

##### 브랜치 전략 :  main: 배포용 / develop: 기능 통합용 / (feature, fix, refactor) branch: 새로운 기능 개발

##### 브랜치 네이밍 :  feature/#이슈번호/작업 내용

