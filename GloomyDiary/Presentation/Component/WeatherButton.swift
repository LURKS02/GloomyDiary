//
//  WeatherCell.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class WeatherButton: UIButton {

    private struct Metric {
        static let imageLeadingPadding: CGFloat = 20
    }
    
    let identifier: String
    
    init(weather: WeatherDTO) {
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
    
    private func setupConfiguration(with weather: WeatherDTO) {
        self.setImage(UIImage(named: weather.imageName)?.resized(width: 63, height: 63), for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .leading
        configuration.imagePadding = Metric.imageLeadingPadding

        var title = AttributedString(weather.name)
        title.font = .온글잎_의연체.title
        title.foregroundColor = .text(.highlight)
        configuration.attributedTitle = title
        configuration.titleAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 14, bottom: 9, trailing: 200)
        
        self.configuration = configuration
        
        let buttonStateHandler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case .normal:
                button.configuration?.background.backgroundColor = .component(.buttonPurple)
            case .selected:
                button.configuration?.background.backgroundColor = .component(.buttonSelectedBlue)
            default:
                return
            }
        }
        self.configurationUpdateHandler = buttonStateHandler
    }
}

extension WeatherButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: CGAffineTransform(scaleX: 0.95, y: 0.95)),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: { }))
        .run()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: {} ))
        .run()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: {}))
        .run()
    }
}
