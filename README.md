<p align="center">
  <img src="https://github.com/user-attachments/assets/e201436f-fdf4-4460-9703-7c47e79757da" width="200" height="200"/>
</p>

<br>

# 우리들의 다이어리, "울다"

![Frame 7](https://github.com/user-attachments/assets/6ae1cdc2-5986-4ddc-9de7-0cdd1b6b7972)

<br>

### Clone & Build

<img src="https://github.com/user-attachments/assets/5688e672-52a9-4180-9ce7-5e8ef6e29cd4" width=300>

API Key 때문에 실제 AI 응답을 받는 기능은 제한되어 있습니다.<br>
Clone 후 GloomyDiaryExample 스킴을 빌드하여 제한된 기능으로 시뮬레이션이 가능합니다.<br>

<br>

### AI 답장을 받는 일기 애플리케이션

> 우리들의 일기 다이어리 "울다"는 하루를 특별하게 기록하는 일기 애플리케이션입니다.<br>
> ChatGPT와 연동하여 사용자가 입력한 일기 내용에 따라 따뜻한 위로와 공감의 답장을 받을 수 있습니다.<br>
> 힐링이 필요한 하루를 울다와 함께 채워보세요.

<br>

### 앱스토어 v1.1.0
[<img src="https://github.com/user-attachments/assets/dba5b62c-9db7-4715-b4cc-2b817503b082" height="50">](https://apps.apple.com/us/app/%EC%9A%B8%EB%8B%A4-%EC%9A%B0%EB%A6%AC%EB%93%A4%EC%9D%98-%EC%9D%BC%EA%B8%B0-%EB%8B%A4%EC%9D%B4%EC%96%B4%EB%A6%AC/id6738892165)

<br>

### [Figma](https://www.figma.com/design/4XnRA4iHJyDHKtFArvhVBG/ULDA?m=auto&t=wEoCwoRnoRfEIwtj-1)

<br>

## 

### 기술 스택
Swift, UIKit, TCA, Swift-Dependencies<br>
RxSwift, RxCocoa, RxRelay, RxGesture<br>
SwiftData, UserDefaults, OpenAI<br>
SnapKit, Lottie, Firebase, Amplitude<br>

<br>

### 흐름도

```mermaid
%%{init: {"theme": "base", "themeVariables": {"fontSize": "12px", "nodeSpacing": "5"}}}%%
flowchart TD
    subgraph 유저가 처음 실행한 경우
    WelcomeVC --> GuideVC
    end
    HomeVC --일기 쓰기--> StartCounselingVC
    GuideVC --> StartCounselingVC --> ChoosingWeatherVC --> ChoosingEmojiVC --> ChoosingCharacterVC --> CounselingVC --> ResultVC
    ResultVC --> HomeVC
    subgraph CircularTabBarVC
    HomeVC
    HistoryVC
    end
    HomeVC--탭 전환-->HistoryVC
    HistoryVC--탭 전환-->HomeVC
    HistoryVC-->HistoryDetailVC
    HistoryDetailVC--삭제 로직---DeleteVC
    HistoryDetailVC--메뉴 열기---HistoryMenuVC
    HistoryDetailVC--이미지 상세보기---ImageDetailVC
    HomeVC--리뷰 요청---ReviewVC
    HomeVC--알림 요청---LocalNotificationVC
```

### 구조
```mermaid
%%{init: {"theme": "base", "themeVariables": {"fontSize": "12px", "nodeSpacing": "5"}}}%%

flowchart TD
    subgraph Presentation
    subgraph ViewController
    View -- send --> Action
    subgraph Store
    Action -- change --> State
    Action --> Effect
    Effect --> Action
    end
    View -- observe --> State
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

### 시연 영상
|과정|영상1|영상2|영상3|
|-|-|-|-|
| 튜토<br>리얼 | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 09 47](https://github.com/user-attachments/assets/babea375-f60d-457e-8b13-4888237f82f7) | | |
| 홈 | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 52 14](https://github.com/user-attachments/assets/24041e1d-dc0e-4087-ad88-0b2a69d1c600) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 49 12](https://github.com/user-attachments/assets/e4de0fac-908f-47e1-9bfb-a338f32e2257) | | 
| 편지<br>쓰기 | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 17 34](https://github.com/user-attachments/assets/2fea2d5a-db4b-4331-855a-028a02a75a37) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 19 18](https://github.com/user-attachments/assets/33c3789e-7484-4200-8d05-4c519321aea3) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 44 23](https://github.com/user-attachments/assets/d7297155-44a8-4263-9717-6beef2a6d6b6) |
| 히스<br>토리 | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 45 46](https://github.com/user-attachments/assets/9414cc03-8047-4969-ba6e-8c9150917659) | ![Simulator Screen Recording - iPhone 16 Pro - 2025-01-20 at 06 46 22](https://github.com/user-attachments/assets/e4f72b02-43ff-45a0-839e-cf227403b643) | | 

<br>

### 트러블슈팅
[[UICollectionView Scroll Hitch 최적화 및 이미지 처리 개선 1]](https://github.com/LURKS02/GloomyDiary/wiki/%08UICollectionView-Scroll-Hitch-%EC%B5%9C%EC%A0%81%ED%99%94-%EB%B0%8F-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%B2%98%EB%A6%AC-%EA%B0%9C%EC%84%A0-1)<br>
[[UICollectionView Scroll Hitch 최적화 및 이미지 처리 개선 2]](https://github.com/LURKS02/GloomyDiary/wiki/%08UICollectionView-Scroll-Hitch-%EC%B5%9C%EC%A0%81%ED%99%94-%EB%B0%8F-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%B2%98%EB%A6%AC-%EA%B0%9C%EC%84%A0-2)<br>
[[UIViewControllerAnimatedTransitioning 관련 이슈]](https://github.com/LURKS02/GloomyDiary/wiki/UIViewControllerAnimatedTransitioning-%EA%B4%80%EB%A0%A8-%EC%9D%B4%EC%8A%88)<br>

<br>

### Conventions
#### 이슈 네이밍
[FEATURE / FIX / REFACTOR / DOCS] 작업 내용

#### 브랜치 전략
- main: 배포용
- develop: 기능 통합용
- feature / fix / refactor branch: 새로운 기능 개발

#### 브랜치 네이밍
feature/#이슈번호/작업 내용

