//
//  WeatherCell.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class WeatherButton: UIButton {

    private enum Metric {
        static let imageLeadingPadding: CGFloat = .deviceAdjustedWidth(20)
        static let imageSize: CGFloat = .deviceAdjustedHeight(63)
    }
    
    let identifier: String
    
    private let weather: Weather
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    private var isPressed: Bool = false {
        didSet {
            if isPressed {
                configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color.withAlphaComponent(0.3)
            } else {
                if !isPicked {
                    configuration?.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
                }
            }
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            if isPicked {
                configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
            } else {
                configuration?.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
            }
        }
    }
    
    init(weather: Weather) {
        self.weather = weather
        self.identifier = weather.identifier
        super.init(frame: .zero)
        
        setupConfiguration(with: weather)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyCircularShape()
    }
    
    private func setupConfiguration(with weather: Weather) {
        let image = AppImage.Component.weather(weather).image
        self.setImage(image.resized(width: Metric.imageSize, height: Metric.imageSize), for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .leading
        configuration.imagePadding = Metric.imageLeadingPadding

        var title = AttributedString(weather.name)
        title.font = .온글잎_의연체.title
        title.foregroundColor = AppColor.Text.main.color
        configuration.attributedTitle = title
        configuration.titleAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 14, bottom: 9, trailing: 200)
        configuration.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
        
        self.configuration = configuration
    }
    
    func changeThemeIfNeeded() {
        let image = AppImage.Component.weather(weather).image
        self.setImage(image.resized(width: Metric.imageSize, height: Metric.imageSize), for: .normal)
        
        guard var configuration = self.configuration else { return }
        var title = AttributedString(weather.name)
        title.font = .온글잎_의연체.title
        title.foregroundColor = AppColor.Text.main.color
        configuration.attributedTitle = title
        
        if isPressed {
            configuration.background.backgroundColor = AppColor.Component.selectedSelectionButton.color.withAlphaComponent(0.3)
        } else if isPicked {
            configuration.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
        } else {
            configuration.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
        }
        
        self.configuration = configuration
    }
}

extension WeatherButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        isPressed = true
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        AnimationGroup(
            animations: [
                Animation(
                    view: self,
                    animationCase: .transform( CGAffineTransform(scaleX: 0.95, y: 0.95)),
                    duration: 0.1
                )],
            mode: .parallel,
            loop: .once(completion: nil)
        )
        .run()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if bounds.contains(location) {
            isPicked = true
        }
        
        isPressed = false
        
        AnimationGroup(
            animations: [
                Animation(
                    view: self,
                    animationCase: .transform( .identity),
                    duration: 0.1
                )],
            mode: .parallel,
            loop: .once(completion: {} )
        )
        .run()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        isPressed = false
        
        AnimationGroup(
            animations: [
                Animation(
                    view: self,
                    animationCase: .transform(
                        .identity
                    ),
                    duration: 0.1
                )],
            mode: .parallel,
            loop: .once(completion: {})
        )
        .run()
    }
}
