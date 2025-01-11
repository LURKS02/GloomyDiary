//
//  ChoosingWeatherView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class ChoosingWeatherView: BaseView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let introduceLabelTopPadding: CGFloat = .verticalValue(153)
        static let nextButtonTopPadding: CGFloat = .verticalValue(50)
        static let stackViewTopPadding: CGFloat = .verticalValue(50)
        static let stackViewHorizontalPadding: CGFloat = .horizontalValue(27)
    }

    
    // MARK: - Views

    private let gradientView = GradientView(colors: [.background(.darkPurple), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    private let introduceLabel = IntroduceLabel().then {
        $0.text = "오늘 날씨는 어땠나요?"
    }
    
    private let weatherButtonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    
    let nextButton = HorizontalButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    var allWeatherButtons: [WeatherButton] {
        self.weatherButtonStackView.arrangedSubviews.compactMap { $0 as? WeatherButton }
    }
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        WeatherDTO.allCases.forEach { weather in
            let button = WeatherButton(weather: weather)
            weatherButtonStackView.addArrangedSubview(button)
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        
    }

    override func addSubviews() {
        addSubview(gradientView)
        addSubview(introduceLabel)
        addSubview(weatherButtonStackView)
        addSubview(nextButton)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.introduceLabelTopPadding)
        }
        
        weatherButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp.bottom).offset(Metric.stackViewTopPadding)
            make.leading.equalToSuperview().inset(Metric.stackViewHorizontalPadding)
            make.trailing.equalToSuperview().inset(Metric.stackViewHorizontalPadding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherButtonStackView.snp.bottom).offset(Metric.nextButtonTopPadding)
        }
    }
    
    func spotlight(to identifier: String?) {
        allWeatherButtons.forEach { button in
            var configuration = button.configuration
            if button.identifier == identifier {
                configuration?.background.backgroundColor = .component(.buttonSelectedBlue)
            } else {
                configuration?.background.backgroundColor = .component(.buttonPurple)
            }
            button.configuration = configuration
        }
    }
}


// MARK: - Animations

extension ChoosingWeatherView {
    func hideAllComponents() {
        subviews.filter { $0 != gradientView }
                .forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: introduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
        await playStackView()
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: nextButton,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    private func playStackView() async {
        weatherButtonStackView.alpha = 1.0
        
        allWeatherButtons.forEach { button in
            button.alpha = 0.0
            button.transform = .identity.translatedBy(x: 0, y: .verticalValue(20))
        }
        
        await withCheckedContinuation { continuation in
            let totalAnimations = allWeatherButtons.count
            var completedAnimations = 0
            
            allWeatherButtons.enumerated().forEach { index, button in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                    self.playButton(button: button) {
                        completedAnimations += 1
                        
                        if completedAnimations == totalAnimations { continuation.resume() }
                    }
                }
            }
        }
    }
    
    private func playButton(button: WeatherButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            button.alpha = 1.0
            button.transform = .identity
        }) { _ in
            completion()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: subviews.filter { $0 != gradientView }
                                               .map { Animation(view: $0,
                                                                animationCase: .fadeOut,
                                                                duration: 0.5)},
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
