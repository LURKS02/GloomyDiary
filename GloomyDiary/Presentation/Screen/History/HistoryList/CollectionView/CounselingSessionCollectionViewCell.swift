//
//  CounselingSessionTableViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import UIKit
import RxSwift
import RxRelay

final class CounselingSessionCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "CounselingSessionCollectionViewCell"
    
    // MARK: - Metric
    
    private struct Metric {
        static let cellVerticalPadding: CGFloat = .verticalValue(25)
        static let cellHorizontalPadding: CGFloat = .verticalValue(30)
        static let characterHorizontalPadding: CGFloat = .verticalValue(25)
        static let collectionViewHorizontalPadding: CGFloat = .horizontalValue(18)
        static let stateLabelTopPadding: CGFloat = .verticalValue(5)
        static let collectionViewTopPadding: CGFloat = .verticalValue(15)
        static let itemSize: CGFloat = .verticalValue(95)
        static let contentLabelTopPadding: CGFloat = .verticalValue(15)
    }
    
    // MARK: - Component
    
    let containerView = UIView()
    
    let titleLabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.font = .온글잎_의연체.heading
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    let stateLabel = UILabel().then {
        $0.textColor = .text(.fogHighlight)
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 5
        $0.itemSize = .init(width: Metric.itemSize, height: Metric.itemSize)
    }
    
    lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.clipsToBounds = true
        $0.register(CounselingImageCollectionViewCell.self, forCellWithReuseIdentifier: CounselingImageCollectionViewCell.identifier)
    }
    
    let characterImageView = UIImageView()
    
    let contentLabel = UILabel().then {
        $0.textColor = .text(.subHighlight)
        $0.font = .온글잎_의연체.title
        $0.textAlignment = .left
        $0.numberOfLines = 3
        $0.contentMode = .topLeft
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    private var urls: [URL] = [] {
        didSet {
            let now: CFTimeInterval = CACurrentMediaTime()
            self.imageCollectionView.reloadData()
            
            DispatchQueue.main.async {
                let elapsedTime = CACurrentMediaTime() - now
                print(">>> elapsedTime", elapsedTime)
            }
        }
    }
    
    private var index: Int?
    
    let indexTappedRelay = PublishRelay<Int>()
    
    var disposeBag = DisposeBag()
    
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
        
        urls = []
        disposeBag = DisposeBag()
    }
    
    private func setup() {
        self.applyCornerRadius(20)
        self.backgroundColor = .component(.buttonPurple)
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.delegate = self
    }
    
    private func addSubviews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(stateLabel)
        containerView.addSubview(imageCollectionView)
        containerView.addSubview(characterImageView)
        containerView.addSubview(contentLabel)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIView.screenWidth - 17 * 2)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.cellVerticalPadding)
            make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
            make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
        }
        
        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Metric.stateLabelTopPadding)
            make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
            make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
        }
        
        characterImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Metric.characterHorizontalPadding)
            make.top.equalToSuperview().offset(Metric.cellVerticalPadding)
            make.size.equalTo(37)
        }
    }
}

extension CounselingSessionCollectionViewCell {
    func saveIndex(_ index: Int) {
        self.index = index
    }
    func configure(with session: CounselingSessionDTO) {
        titleLabel.text = session.title
        stateLabel.text = "날씨 \(session.weather.name), \(session.emoji.description)"
        characterImageView.image = UIImage(named: session.counselor.imageName)
        contentLabel.text = session.query
        
        resetConstraints(withImages: !session.urls.isEmpty)
        self.urls = session.urls
    }
    
    func resetConstraints(withImages: Bool) {
        if withImages {
            imageCollectionView.isHidden = false
            
            imageCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(stateLabel.snp.bottom).offset(Metric.collectionViewTopPadding)
                make.horizontalEdges.equalToSuperview().inset(Metric.collectionViewHorizontalPadding)
                make.height.equalTo(Metric.itemSize)
            }
            
            contentLabel.snp.remakeConstraints { make in
                make.top.equalTo(imageCollectionView.snp.bottom).offset(Metric.contentLabelTopPadding)
                make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
                make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
                make.bottom.equalToSuperview().offset(-Metric.cellVerticalPadding)
            }
        } else {
            imageCollectionView.isHidden = true
            
            contentLabel.snp.remakeConstraints { make in
                make.top.equalTo(stateLabel.snp.bottom).offset(Metric.contentLabelTopPadding)
                make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
                make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
                make.bottom.equalToSuperview().offset(-Metric.cellVerticalPadding)
            }
        }
    }
}

extension CounselingSessionCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CounselingImageCollectionViewCell.identifier, for: indexPath) as? CounselingImageCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: urls[indexPath.row])
        
        return cell
    }
}

extension CounselingSessionCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        guard let index else { return }
        indexTappedRelay.accept(index)
    }
}

extension CounselingSessionCollectionViewCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.backgroundColor = .component(.buttonSelectedBlue).withAlphaComponent(0.3)
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity.scaledBy(x: 0.97, y: 0.97)),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        self.backgroundColor = .component(.buttonSelectedBlue).withAlphaComponent(0.3)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.backgroundColor = .component(.buttonPurple)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = .component(.buttonPurple)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
        
    }
}
