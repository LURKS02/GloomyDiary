//
//  CounselingSessionTableViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import UIKit
import RxSwift

final class CounselingSessionTableViewCell: UITableViewCell {
    
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
    
    private var images: [UIImage] = [] {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        images = []
        disposeBag = DisposeBag()
    }
    
    private func setup() {
        self.applyCornerRadius(20)
        self.selectionStyle = .none
        self.backgroundColor = .component(.buttonPurple)
        self.imageCollectionView.dataSource = self
    }
    
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(stateLabel)
        contentView.addSubview(imageCollectionView)
        contentView.addSubview(characterImageView)
        contentView.addSubview(contentLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.cellVerticalPadding)
            make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
            make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
        }
        
        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Metric.stateLabelTopPadding)
            make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
        }
        
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(Metric.collectionViewTopPadding)
            make.horizontalEdges.equalToSuperview().inset(Metric.collectionViewHorizontalPadding)
            make.height.equalTo(Metric.itemSize)
        }
        
        characterImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Metric.characterHorizontalPadding)
            make.top.equalToSuperview().offset(Metric.cellVerticalPadding)
            make.size.equalTo(37)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(Metric.contentLabelTopPadding)
            make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
            make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
            make.bottom.equalToSuperview().offset(-Metric.cellVerticalPadding)
        }
    }
}

extension CounselingSessionTableViewCell: TableViewConfigurationBindable {
    func bind(with configuration: TableViewCellConfigurable) {
        guard let configuration = configuration as? CounselingSessionTableViewCellConfiguration else { return }
        let counselingSessionDTO = configuration.counselingSessionDTO
        
        titleLabel.text = counselingSessionDTO.title
        stateLabel.text = "날씨 \(counselingSessionDTO.weather.name), \(counselingSessionDTO.emoji.description)"
        characterImageView.image = UIImage(named: counselingSessionDTO.counselor.imageName)
        contentLabel.text = counselingSessionDTO.query
        
        if counselingSessionDTO.images.isEmpty {
            contentLabel.snp.remakeConstraints { make in
                make.top.equalTo(stateLabel.snp.bottom).offset(Metric.contentLabelTopPadding)
                make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
                make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
                make.bottom.equalToSuperview().offset(-Metric.cellVerticalPadding)
            }
        } else {
            contentLabel.snp.remakeConstraints { make in
                make.top.equalTo(imageCollectionView.snp.bottom).offset(Metric.contentLabelTopPadding)
                make.leading.equalToSuperview().offset(Metric.cellHorizontalPadding)
                make.trailing.equalToSuperview().offset(-Metric.cellHorizontalPadding)
                make.bottom.equalToSuperview().offset(-Metric.cellVerticalPadding)
            }
        }
        
        images = counselingSessionDTO.images.compactMap { UIImage(data: $0) }
    }
}

extension CounselingSessionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CounselingImageCollectionViewCell.identifier, for: indexPath) as? CounselingImageCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: images[indexPath.row])
        
        return cell
    }
}

extension CounselingSessionTableViewCell {
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
