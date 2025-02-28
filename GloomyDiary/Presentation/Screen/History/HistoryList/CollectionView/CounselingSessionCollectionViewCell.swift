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
    
    typealias Section = HistoryImageSection
    typealias Item = HistoryImageItem
    
    static let identifier: String = "CounselingSessionCollectionViewCell"
    
    // MARK: - Metric
    
    private enum Metric {
        static let cellVerticalPadding: CGFloat = .deviceAdjustedHeight(25)
        static let cellHorizontalPadding: CGFloat = .deviceAdjustedHeight(30)
        static let characterHorizontalPadding: CGFloat = .deviceAdjustedHeight(25)
        static let collectionViewHorizontalPadding: CGFloat = .deviceAdjustedWidth(18)
        static let stateLabelTopPadding: CGFloat = .deviceAdjustedHeight(5)
        static let collectionViewTopPadding: CGFloat = .deviceAdjustedHeight(15)
        static let itemSize: CGFloat = .deviceAdjustedHeight(95)
        static let contentLabelTopPadding: CGFloat = .deviceAdjustedHeight(15)
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
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: imageCollectionView, cellProvider: provideCell)
    
    let characterImageView = UIImageView()
    
    let contentLabel = UILabel().then {
        $0.textColor = .text(.subHighlight)
        $0.font = .온글잎_의연체.title
        $0.textAlignment = .left
        $0.numberOfLines = 3
        $0.contentMode = .topLeft
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    private var imageIDs: [UUID] = [] {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.imageIDs.map { Item(imageID: $0) })
            dataSource.apply(snapshot, animatingDifferences: false)
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
        
        imageIDs = []
        disposeBag = DisposeBag()
    }
    
    private func setup() {
        self.applyCornerRadius(20)
        self.backgroundColor = .component(.buttonPurple)
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
    
    func configureWithDummy(with session: Session) {
        titleLabel.text = session.title
        stateLabel.text = "날씨 \(session.weather.name), \(session.emoji.description)"
        contentLabel.text = session.query
        resetConstraints(withImages: !session.imageIDs.isEmpty)
    }
    
    func configure(with session: Session) {
        titleLabel.text = session.title
        stateLabel.text = "날씨 \(session.weather.name), \(session.emoji.description)"
        characterImageView.image = UIImage(named: session.counselor.imageName)
        contentLabel.text = session.query
        
        resetConstraints(withImages: !session.imageIDs.isEmpty)
        self.imageIDs = session.imageIDs
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
    
    func provideCell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CounselingImageCollectionViewCell.identifier, for: indexPath) as? CounselingImageCollectionViewCell else { return nil }
        cell.configure(with: imageIDs[indexPath.row])
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
                                               animationCase: .transform( .identity.scaledBy(x: 0.97, y: 0.97)),
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
                                               animationCase: .transform( .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = .component(.buttonPurple)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform( .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
        
    }
}
