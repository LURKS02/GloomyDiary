//
//  ImageAssets.swift
//  GloomyDiary
//
//  Created by 디해 on 4/17/25.
//

import Dependencies
import UIKit

enum AppImage {
    static var resolvedDefault: AppearanceMode {
        @Dependency(\.themeScheduler) var themeScheduler
        
        return themeScheduler.resolvedDefault
    }
    
    enum Character {
        case ghost(Emoji)
        case counselor(CounselingCharacter, Emoji)
        
        enum Emoji {
            case normal
            case happy
            case crying
        }
        
        var image: UIImage {
            return image(for: AppEnvironment.appearanceMode)
        }
        
        func image(for mode: AppearanceMode) -> UIImage {
            switch self {
            case .ghost(let emoji):
                switch emoji {
                case .normal:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "ghost_dark")!
                    case .light:
                        UIImage(named: "ghost_light")!
                    }
                    
                case .happy:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "happyGhost_dark")!
                    case .light:
                        UIImage(named: "happyGhost_light")!
                    }
                    
                case .crying:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "cryingGhost_dark")!
                    case .light:
                        UIImage(named: "cryingGhost_light")!
                    }
                }
                
            case .counselor(let character, let emoji):
                switch character {
                case .chan:
                    switch emoji {
                    case .normal:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "chan_dark")!
                        case .light:
                            UIImage(named: "chan_light")!
                        }
                        
                    case .happy:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "chan_dark")!
                        case .light:
                            UIImage(named: "chan_light")!
                        }
                        
                    case .crying:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "cryingChan_dark")!
                        case .light:
                            UIImage(named: "cryingChan_light")!
                        }
                    }
                    
                case .gomi:
                    switch emoji {
                    case .normal:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "gomi_dark")!
                        case .light:
                            UIImage(named: "gomi_light")!
                        }
                        
                    case .happy:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "gomi_dark")!
                        case .light:
                            UIImage(named: "gomi_light")!
                        }
                        
                    case .crying:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "cryingGomi_dark")!
                        case .light:
                            UIImage(named: "cryingGomi_light")!
                        }
                    }
                    
                case .beomji:
                    switch emoji {
                    case .normal:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "beomji_dark")!
                        case .light:
                            UIImage(named: "beomji_light")!
                        }
                        
                    case .happy:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "beomji_dark")!
                        case .light:
                            UIImage(named: "beomji_light")!
                        }
                        
                    case .crying:
                        switch mode {
                        case .default:
                            image(for: resolvedDefault)
                        case .dark:
                            UIImage(named: "cryingBeomji_dark")!
                        case .light:
                            UIImage(named: "cryingBeomji_light")!
                        }
                    }
                }
            }
        }
    }
    
    enum Component {
        case skyBadge
        case letter
        case weather(Weather)
        case emoji(Emoji)
        
        var image: UIImage {
            return image(for: AppEnvironment.appearanceMode)
        }
        
        func image(for mode: AppearanceMode) -> UIImage {
            switch self {
            case .skyBadge:
                switch mode {
                case .default:
                    image(for: resolvedDefault)
                case .dark:
                    UIImage(named: "moon")!.withTintColor(#colorLiteral(red: 1, green: 0.7960784314, blue: 0.5019607843, alpha: 1))
                case .light:
                    UIImage(named: "sun")!.withTintColor(#colorLiteral(red: 1, green: 0.9058823529, blue: 0.6549019608, alpha: 1))
                }
                
            case .letter:
                switch mode {
                case .default:
                    image(for: resolvedDefault)
                case .dark:
                    UIImage(named: "letter_dark")!
                case .light:
                    UIImage(named: "letter_light")!
                }
                
            case .weather(let weather):
                switch weather {
                case .sunny:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "sunny_dark")!
                    case .light:
                        UIImage(named: "sunny_light")!
                    }
                    
                case .rainy:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "rainy_dark")!
                    case .light:
                        UIImage(named: "rainy_light")!
                    }
                    
                case .cloudy:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "cloudy_dark")!
                    case .light:
                        UIImage(named: "cloudy_light")!
                    }
                    
                case .thunder:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "thunder_dark")!
                    case .light:
                        UIImage(named: "thunder_light")!
                    }
                    
                case .snowy:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "snowy_dark")!
                    case .light:
                        UIImage(named: "snowy_light")!
                    }
                }
                
            case .emoji(let emoji):
                switch emoji {
                case .happy:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "happy_dark")!
                    case .light:
                        UIImage(named: "happy_light")!
                    }
                    
                case .angry:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "angry_dark")!
                    case .light:
                        UIImage(named: "angry_light")!
                    }
                    
                case .confused:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "confused_dark")!
                    case .light:
                        UIImage(named: "confused_light")!
                    }
                    
                case .embarrassed:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "embarrassed_dark")!
                    case .light:
                        UIImage(named: "embarrassed_light")!
                    }
                    
                case .excited:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "excited_dark")!
                    case .light:
                        UIImage(named: "excited_light")!
                    }
                    
                case .hard:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "hard_dark")!
                    case .light:
                        UIImage(named: "hard_light")!
                    }
                    
                case .normal:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "normal_dark")!
                    case .light:
                        UIImage(named: "normal_light")!
                    }
                    
                case .sad:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "sad_dark")!
                    case .light:
                        UIImage(named: "sad_light")!
                    }
                    
                case .surprised:
                    switch mode {
                    case .default:
                        image(for: resolvedDefault)
                    case .dark:
                        UIImage(named: "surprised_dark")!
                    case .light:
                        UIImage(named: "surprised_light")!
                    }
                }
            }
        }
    }
    
    enum TabBar {
        case home
        case history
        case setting
        
        func image(isSelected: Bool) -> UIImage {
            return image(isSelected: isSelected, theme: AppEnvironment.appearanceMode)
        }
        
        func image(isSelected: Bool, theme: AppearanceMode) -> UIImage {
            switch self {
            case .home:
                let image = UIImage(named: "home")!
                return image.withTintColor(AppColor.Component.tabBarItem(isSelected).color)
            case .history:
                let image = UIImage(named: "history")!
                return image.withTintColor(AppColor.Component.tabBarItem(isSelected).color)
            case .setting:
                let image = UIImage(named: "setting")!
                return image.withTintColor(AppColor.Component.tabBarItem(isSelected).color)
            }
        }
    }
    
    enum JSON {
        case sparkles
        case pulsingCircle
        case stars
        
        var name: String {
            return name(for: AppEnvironment.appearanceMode)
        }
        
        func name(for mode: AppearanceMode) -> String {
            switch self {
            case .sparkles:
                switch mode {
                case .default:
                    name(for: resolvedDefault)
                case .dark:
                    "sparkles_dark"
                case .light:
                    "sparkles_light"
                }
                
            case .pulsingCircle:
                switch mode {
                case .default:
                    name(for: resolvedDefault)
                case .dark:
                    "pulsingCircle_dark"
                case .light:
                    "pulsingCircle_light"
                }
                
            case .stars:
                switch mode {
                case .default:
                    name(for: resolvedDefault)
                case .dark:
                    "stars_dark"
                case .light:
                    "stars_light"
                }
            }
        }
    }
}
