//
//  HistoryDetailImageView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/20/24.
//

import Combine
import CombineCocoa
import UIKit

final class HistoryDetailImageView: UIView {
    
    // MARK: - Views
    
    private lazy var scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
    }
    
    private let pageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.pageIndicatorTintColor = .white.withAlphaComponent(0.5)
        $0.currentPageIndicatorTintColor = .white
        $0.hidesForSinglePage = true
    }
    
    private let numberLabel = NormalLabel().then {
        $0.font = .온글잎_의연체.body
        $0.textColor = .white
    }
    
    private let labelBackgroundView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    
    // MARK: - Properties

    private var imageIDs: [UUID] = []
    
    private let imageSize: CGFloat
    
    private let imageTap = UITapGestureRecognizer()
    
    let imageTapSubject = PassthroughSubject<UUID, Never>()
    
    
    // MARK: - Initialize
    
    init(imageSize: CGFloat) {
        self.imageSize = imageSize
        
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
        
        bind()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        self.addGestureRecognizer(imageTap)
        
        imageTap.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let page = pageControl.currentPage
                imageTapSubject.send(imageIDs[page])
            }
            .store(in: &cancellables)
    }
    
    func configure(with imageIDs: [UUID]) {
        for index in imageIDs.indices {
            let imageView = UIImageView()
            guard let downsampledImage = try? ImageCache.shared.getImage(
                forKey: imageIDs[index],
                pointSize: .init(width: imageSize, height: imageSize)
            ) else { return }
            
            imageView.image = downsampledImage
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.applyCornerRadius(10)
            
            scrollView.addSubview(imageView)
        }
        
        pageControl.numberOfPages = imageIDs.count
        numberLabel.text = "1/\(imageIDs.count)"
        self.imageIDs = imageIDs
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        applyCornerRadius(10)
    }
    
    private func addSubviews() {
        addSubview(scrollView)
        addSubview(pageControl)
        addSubview(labelBackgroundView)
        labelBackgroundView.addSubview(numberLabel)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(5)
        }
        
        labelBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(15)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(2)
            make.horizontalEdges.equalToSuperview().inset(13)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViews: [UIImageView] = scrollView.subviews.compactMap { $0 as? UIImageView }
        for (index, imageView) in imageViews.enumerated() {
            let xPosition = self.bounds.width * CGFloat(index)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.bounds.width, height: self.bounds.height)
        }
        scrollView.contentSize.height = self.bounds.height
        scrollView.contentSize.width = self.bounds.width * CGFloat(imageViews.count)
        labelBackgroundView.applyCircularShape()
    }
}


// MARK: - Scroll Delegate

extension HistoryDetailImageView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(round(scrollView.contentOffset.x / self.bounds.width))
        self.numberLabel.text = "\(pageControl.currentPage+1)/\(pageControl.numberOfPages)"
    }
}
