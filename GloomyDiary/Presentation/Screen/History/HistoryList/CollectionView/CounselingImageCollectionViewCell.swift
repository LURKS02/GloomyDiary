//
//  CounselingImageCollectionViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 12/19/24.
//

import UIKit
import ImageIO
import Lottie

final class CounselingImageCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CounselingImageCell"
    
    // MARK: - Metric
    
    private enum Metric {
        static let itemSize: CGFloat = .verticalValue(95)
    }
    
    lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let lottieView = LottieAnimationView(name: "skeleton").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
        $0.play()
    }
    
    private var workItem: DispatchWorkItem?
    
    private var currentURL: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        workItem?.cancel()
        currentURL = nil
        workItem = nil
        lottieView.isHidden = false
        imageView.image = nil
    }
    
    private func setup() {
        contentView.applyCornerRadius(10)
        contentView.isUserInteractionEnabled = false
    }
    
    private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(lottieView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        lottieView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with url: URL) {
        workItem?.cancel()
        
        let newWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            let downsampledImage = UIImage.downsample(imageAt: url, to: .init(width: Metric.itemSize, height: Metric.itemSize))
            guard let downsampledImage else { return }
            DispatchQueue.main.async {
                guard url == self.currentURL else { return }
                self.lottieView.isHidden = true
                UIView.transition(with: self.imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.imageView.image = downsampledImage
                })
            }
        }
        
        self.workItem = newWorkItem
        self.currentURL = url
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(250), execute: newWorkItem)
    }
}
