//
//  AppColor.swift
//  GloomyDiary
//
//  Created by 디해 on 8/2/24.
//

import UIKit.UIColor

enum AppColor {
    enum Text {
        case highlight
        case dark
        case warning
        case buttonDisabled
        case buttonSubHighlight
        case subHighlight
        case fogHighlight
        
        var color: UIColor {
            switch self {
            case .highlight:
                #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            case .dark:
                #colorLiteral(red: 0.4, green: 0.3843137255, blue: 0.4196078431, alpha: 1)
            case .warning:
                #colorLiteral(red: 0.8, green: 0.3058823529, blue: 0.4549019608, alpha: 1)
            case .buttonDisabled:
                #colorLiteral(red: 0.4274509804, green: 0.4, blue: 0.4666666667, alpha: 1)
            case .buttonSubHighlight:
                #colorLiteral(red: 0.6117647059, green: 0.5921568627, blue: 0.6392156863, alpha: 1)
            case .subHighlight:
                #colorLiteral(red: 0.7568627451, green: 0.7490196078, blue: 0.7725490196, alpha: 1)
            case .fogHighlight:
                #colorLiteral(red: 0.568627451, green: 0.537254902, blue: 0.6039215686, alpha: 1)
            }
        }
    }
    
    enum Background {
        case mainPurple
        case darkPurple
        
        var color: UIColor {
            switch self {
            case .mainPurple:
                #colorLiteral(red: 0.2784313725, green: 0.231372549, blue: 0.3411764706, alpha: 1)
            case .darkPurple:
                #colorLiteral(red: 0.1058823529, green: 0.09803921569, blue: 0.2196078431, alpha: 1)
            }
        }
    }
    
    enum Component {
        case white
        case blackPurple
        case darkPurple
        case fogPurple
        case buttonPurple
        case buttonDisabledPurple
        case lightGray
        case fogGray
        case textFieldGray
        case buttonSelectedBlue
        
        var color: UIColor {
            switch self {
            case .white:
                #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            case .blackPurple:
                #colorLiteral(red: 0.137254902, green: 0.1137254902, blue: 0.168627451, alpha: 1)
            case .darkPurple:
                #colorLiteral(red: 0.1568627451, green: 0.1333333333, blue: 0.2117647059, alpha: 1)
            case .fogPurple:
                #colorLiteral(red: 0.2235294118, green: 0.1843137255, blue: 0.2745098039, alpha: 1)
            case .buttonPurple:
                #colorLiteral(red: 0.1960784314, green: 0.1647058824, blue: 0.2392156863, alpha: 1)
            case .buttonDisabledPurple:
                #colorLiteral(red: 0.2274509804, green: 0.1882352941, blue: 0.2784313725, alpha: 1)
            case .lightGray:
                #colorLiteral(red: 0.7803921569, green: 0.7254901961, blue: 0.7254901961, alpha: 1)
            case .fogGray:
                #colorLiteral(red: 0.3725490196, green: 0.3333333333, blue: 0.3843137255, alpha: 1)
            case .textFieldGray:
                #colorLiteral(red: 0.3450980392, green: 0.2901960784, blue: 0.4117647059, alpha: 1)
            case .buttonSelectedBlue:
                #colorLiteral(red: 0.3254901961, green: 0.3019607843, blue: 0.4431372549, alpha: 1)
            }
        }
    }
}
