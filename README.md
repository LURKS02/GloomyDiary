<p align="center">
  <img src="https://github.com/user-attachments/assets/e201436f-fdf4-4460-9703-7c47e79757da" width="200" height="200"/>
</p>

<br>

# 우리들의 다이어리, "울다"

![Frame 7](https://github.com/user-attachments/assets/6ae1cdc2-5986-4ddc-9de7-0cdd1b6b7972)

<br>

### AI 답장을 받는 일기 애플리케이션

> 우리들의 일기 다이어리 "울다"는 하루를 특별하게 기록하는 일기 애플리케이션입니다.<br>
> ChatGPT와 연동하여 사용자가 입력한 일기 내용에 따라 따뜻한 위로와 공감의 답장을 받을 수 있습니다.<br>
> 힐링이 필요한 하루를 울다와 함께 채워보세요.

<br>

### [앱스토어 v1.1.0](https://apps.apple.com/us/app/%EC%9A%B8%EB%8B%A4-%EC%9A%B0%EB%A6%AC%EB%93%A4%EC%9D%98-%EC%9D%BC%EA%B8%B0-%EB%8B%A4%EC%9D%B4%EC%96%B4%EB%A6%AC/id6738892165)

### [Figma](https://www.figma.com/design/4XnRA4iHJyDHKtFArvhVBG/ULDA?m=auto&t=wEoCwoRnoRfEIwtj-1)

## 

### 기술 스택
Swift, UIKit, TCA, Swift-Dependencies<br>
RxSwift, RxCocoa, RxRelay, RxGesture<br>
SwiftData, UserDefaults, OpenAI<br>
SnapKit, Lottie, Firebase, Amplitude<br>

<br>

### MVVM 구조
```mermaid
flowchart LR
    subgraph ViewController
    View -- send --> Action
    subgraph Store
    Action -- change --> State
    Action --> Effect
    Effect --> Action
    end
    View -- observe --> State
    end
```
