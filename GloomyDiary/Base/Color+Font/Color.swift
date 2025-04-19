//
//  AppColor.swift
//  GloomyDiary
//
//  Created by 디해 on 8/2/24.
//

import UIKit.UIColor

enum AppColor {
    enum Text {
        case main
        case warning
        case disabled
        case reject
        case subHighlight
        case fogHighlight
        
        var color: UIColor {
            switch self {
            case .main:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.2537425756, green: 0.2537425756, blue: 0.2537425756, alpha: 1)
                case .dark:
                    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.2537425756, green: 0.2537425756, blue: 0.2537425756, alpha: 1)
                }
            case .warning:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 1, green: 0.3803921569, blue: 0.5647058824, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.8, green: 0.3058823529, blue: 0.4549019608, alpha: 1)
                case .light:
                    #colorLiteral(red: 1, green: 0.3803921569, blue: 0.5647058824, alpha: 1)
                }
                
            case .disabled:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.5098039216, green: 0.5921568627, blue: 0.6980392157, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.4274509804, green: 0.4, blue: 0.4666666667, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.5098039216, green: 0.5921568627, blue: 0.6980392157, alpha: 1)
                }
                
            case .reject:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.5215686275, green: 0.5568627451, blue: 0.6235294118, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.6117647059, green: 0.5921568627, blue: 0.6392156863, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.5215686275, green: 0.5568627451, blue: 0.6235294118, alpha: 1)
                }
                
            case .subHighlight:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.7568627451, green: 0.7490196078, blue: 0.7725490196, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
                }
                
            case .fogHighlight:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.5098039216, green: 0.6078431373, blue: 0.6705882353, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.568627451, green: 0.537254902, blue: 0.6039215686, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.5098039216, green: 0.6078431373, blue: 0.6705882353, alpha: 1)
                }
            }
        }
    }
    
    enum Background {
        case main
        case sub
        case letter
        case historyCell
        case skeleton
        
        var color: UIColor {
            switch self {
            case .main:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.8470588235, green: 0.9294117647, blue: 0.9568627451, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.2784313725, green: 0.231372549, blue: 0.3411764706, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.8470588235, green: 0.9294117647, blue: 0.9568627451, alpha: 1)
                }
                
            case .sub:
                switch AppEnvironment.appearanceMode {
                case .default :
                    #colorLiteral(red: 0.5960784314, green: 0.8392156863, blue: 1, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.1058823529, green: 0.09803921569, blue: 0.2196078431, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.5960784314, green: 0.8392156863, blue: 1, alpha: 1)
                }
                
            case .letter:
                switch AppEnvironment.appearanceMode {
                case .default :
                    #colorLiteral(red: 0.9333333333, green: 0.9764705882, blue: 1, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.1960784314, green: 0.1647058824, blue: 0.2392156863, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.9333333333, green: 0.9764705882, blue: 1, alpha: 1)
                }
                
            case .historyCell:
                switch AppEnvironment.appearanceMode {
                case .default :
                    #colorLiteral(red: 0.7647058824, green: 0.8823529412, blue: 0.937254902, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.1960784314, green: 0.1647058824, blue: 0.2392156863, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.7647058824, green: 0.8823529412, blue: 0.937254902, alpha: 1)
                }
                
            case .skeleton:
                switch AppEnvironment.appearanceMode {
                case .default :
                    .white.withAlphaComponent(0.3)
                case .dark:
                    .black.withAlphaComponent(0.3)
                case .light:
                    .white.withAlphaComponent(0.3)
                }
            }
        }
    }
    
    enum Component {
        case subHorizontalButton
        case mainPoint
        
        case horizontalButton
        case selectedHorizontalButton
        
        case disabledSelectionButton
        case selectedSelectionButton
        
        case disabledButton
        case textFieldBackground
        case selectedButton
        case navigationItem
        case tabBarItem(Bool)
        case roundIcon
        case roundIconLiteral
        
        var color: UIColor {
            switch self {
            case .subHorizontalButton:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.137254902, green: 0.1137254902, blue: 0.168627451, alpha: 1)
                case .light:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                }
                
            case .mainPoint:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.1568627451, green: 0.1333333333, blue: 0.2117647059, alpha: 1)
                case .light:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                }
                
            case .horizontalButton:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.9529411765, green: 0.9843137255, blue: 1, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.1960784314, green: 0.1647058824, blue: 0.2392156863, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.9529411765, green: 0.9843137255, blue: 1, alpha: 1)
                }
                
            case .selectedHorizontalButton:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 1, green: 0.9568627451, blue: 0.8705882353, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.3254901961, green: 0.3019607843, blue: 0.4431372549, alpha: 1)
                case .light:
                    #colorLiteral(red: 1, green: 0.9568627451, blue: 0.8705882353, alpha: 1)
                }
                
            case .disabledSelectionButton:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.8941176471, green: 0.9647058824, blue: 1, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.1960784314, green: 0.1647058824, blue: 0.2392156863, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.8941176471, green: 0.9647058824, blue: 1, alpha: 1)
                }
                
            case .selectedSelectionButton:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.3254901961, green: 0.3019607843, blue: 0.4431372549, alpha: 1)
                case .light:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                }
                
            case .disabledButton:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.8117647059, green: 0.8823529412, blue: 0.9098039216, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.2274509804, green: 0.1882352941, blue: 0.2784313725, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.8117647059, green: 0.8823529412, blue: 0.9098039216, alpha: 1)
                }
                
            case .textFieldBackground:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.9607843137, green: 0.9803921569, blue: 0.9882352941, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.3450980392, green: 0.2901960784, blue: 0.4117647059, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.9607843137, green: 0.9803921569, blue: 0.9882352941, alpha: 1)
                }
                
            case .selectedButton:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.3254901961, green: 0.3019607843, blue: 0.4431372549, alpha: 1)
                case .light:
                    #colorLiteral(red: 1, green: 0.937254902, blue: 0.8117647059, alpha: 1)
                }
                
            case .navigationItem:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.5411764706, green: 0.6117647059, blue: 0.6901960784, alpha: 1)
                case .dark:
                    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.5411764706, green: 0.6117647059, blue: 0.6901960784, alpha: 1)
                }
                
            case .tabBarItem(let isSelected):
                if isSelected {
                    switch AppEnvironment.appearanceMode {
                    case .default:
                        #colorLiteral(red: 0.7764705882, green: 0.7019607843, blue: 0.5725490196, alpha: 1)
                    case .dark:
                        #colorLiteral(red: 0.9411764706, green: 0.9058823529, blue: 0.8549019608, alpha: 1)
                    case .light:
                        #colorLiteral(red: 0.7764705882, green: 0.7019607843, blue: 0.5725490196, alpha: 1)
                    }
                } else {
                    switch AppEnvironment.appearanceMode {
                    case .default:
                        #colorLiteral(red: 0.9137254902, green: 0.8431372549, blue: 0.7254901961, alpha: 1)
                    case .dark:
                        #colorLiteral(red: 0.4, green: 0.3843137255, blue: 0.4196078431, alpha: 1)
                    case .light:
                        #colorLiteral(red: 0.9137254902, green: 0.8431372549, blue: 0.7254901961, alpha: 1)
                    }
                }
                
            case .roundIcon:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.8117647059, green: 0.8666666667, blue: 0.9098039216, alpha: 1)
                case .dark:
                    #colorLiteral(red: 0.137254902, green: 0.1137254902, blue: 0.168627451, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.8117647059, green: 0.8666666667, blue: 0.9098039216, alpha: 1)
                }
                
            case .roundIconLiteral:
                switch AppEnvironment.appearanceMode {
                case .default:
                    #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
                case .dark:
                    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                case .light:
                    #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
                }
            }
        }
    }
}
