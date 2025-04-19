//
//  ChoosingWeatherView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class ChoosingWeatherView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let NormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(153)
        static let nextButtonTopPadding: CGFloat = .deviceAdjustedHeight(50)
        static let stackViewTopPadding: CGFloat = .deviceAdjustedHeight(50)
        static let stackViewHorizontalPadding: CGFloat = .deviceAdjustedWidth(27)
    }

    
    // MARK: - Views

    private let gradientView = GradientView(
        colors: [
            AppColor.Background.sub.color,
            AppColor.Background.main.color
        ],
        locations: [0.0, 0.5, 1.0]
    )
    
    private let introduceLabel = NormalLabel().then {
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
    
    
    // MARK: - Properties
    
    var allWeatherButtons: [WeatherButton] {
        self.weatherButtonStackView.arrangedSubviews.compactMap { $0 as? WeatherButton }
    }
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        Weather.allCases.forEach { weather in
            let button = WeatherButton(weather: weather)
            weatherButtonStackView.addArrangedSubview(button)
        }
    }

    private func addSubviews() {
        addSubview(gradientView)
        addSubview(introduceLabel)
        addSubview(weatherButtonStackView)
        addSubview(nextButton)
    }
    
    private func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.NormalLabelTopPadding)
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
                configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
            } else {
                configuration?.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
            }
            button.configuration = configuration
        }
    }
}


// MARK: - Animations

extension ChoosingWeatherView {
    func hideAllComponents() {
        subviews.exclude(gradientView).forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents(duration: TimeInterval) async {
        let percentages: [CGFloat] = [25, 50, 25]
        let calculatedDurations = percentages.map { duration * $0 / 100 }
        
        await playShowingLabel(duration: calculatedDurations[0])
        await playStackView(duration: calculatedDurations[1])
        await playShowingNextButton(duration: calculatedDurations[2])
    }
    
    @MainActor
    func playShowingLabel(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: introduceLabel,
                              animationCase: .fadeIn,
                              duration: duration)
                ],
                mode: .serial,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    private func playStackView(duration: TimeInterval) async {
        let buttonDuration: TimeInterval = 0.5
        weatherButtonStackView.alpha = 1.0
        
        allWeatherButtons.forEach { button in
            button.alpha = 0.0
            button.transform = .identity.translatedBy(x: 0, y: .deviceAdjustedHeight(20))
        }
        
        await withCheckedContinuation { continuation in
            let totalAnimations = allWeatherButtons.count
            var completedAnimations = 0
            
            let reciprocal = (duration - buttonDuration) / Double(allWeatherButtons.count)
            
            allWeatherButtons.enumerated().forEach { index, button in
                DispatchQueue.main.asyncAfter(deadline: .now() + reciprocal * Double(index)) {
                    self.playButton(button: button, duration: buttonDuration) {
                        completedAnimations += 1
                        
                        if completedAnimations == totalAnimations { continuation.resume() }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func playShowingNextButton(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: nextButton,
                              animationCase: .fadeIn,
                              duration: duration)
                ],
                mode: .serial,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    private func playButton(
        button: WeatherButton,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        UIView.animate(withDuration: duration, animations: {
            button.alpha = 1.0
            button.transform = .identity
        }) { _ in
            completion()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: subviews.exclude(gradientView).map {
                    Animation(
                        view: $0,
                        animationCase: .fadeOut,
                        duration: duration
                    )
                },
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
