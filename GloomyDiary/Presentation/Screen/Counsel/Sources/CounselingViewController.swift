//
//  CounselingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import CombineCocoa
import ComposableArchitecture
import PhotosUI
import UIKit

final class CounselingViewController: BaseViewController<CounselingView> {
    
    @UIBindable var store: StoreOf<Counseling>
    
    @Dependency(\.counselRepository) var counselRepository
    @Dependency(\.userSetting) var userSetting
    
    
    // MARK: - Properties
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<CounselingViewSection, CounselingViewItem> = UICollectionViewDiffableDataSource<CounselingViewSection, CounselingViewItem>(collectionView: contentView.photoCollectionView) { collectionView, indexPath, item in
        switch item {
        case .selectItem(let count, let maxCount):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CounselingPhotoSelectionCollectionViewCell.identifier,
                for: indexPath
            ) as? CounselingPhotoSelectionCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configure(count: count, maxCount: maxCount)
            return cell
            
        case .photoItem(_, let selection):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CounselingPhotoCollectionViewCell.identifier,
                for: indexPath
            ) as? CounselingPhotoCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configure(with: selection, delegate: self)
            return cell
        }
    }
    
    private var isKeyboardShowing: Bool = false {
        didSet {
            updateContentOffset()
        }
    }
    
    private var isPickerProcessing: Bool = false
    
    
    // MARK: - Initialize

    init(store: StoreOf<Counseling>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        initializeSnapshot()
        
        contentView.tapGesture.addTarget(self, action: #selector(viewTouched))
        self.navigationItem.hidesBackButton = true
        self.navigationController?.delegate = self
    }
    
    
    // MARK: - Touch Cycle
    
    @objc func viewTouched() {
        self.contentView.sendingLetterView.endEditing(true)
    }
}


// MARK: - bind

private extension CounselingViewController {
    private func bind() {
        contentView.photoCollectionView.dragDelegate = self
        contentView.photoCollectionView.dropDelegate = self
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.contentView.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        contentView.photoCollectionView.didSelectItemPublisher
            .sink { [weak self] indexPath in
                guard let self else { return }
                let snapshot = dataSource.snapshot()
                let items = snapshot.itemIdentifiers
                let selectedItem = items[indexPath.row]
                
                switch selectedItem {
                case .selectItem:
                    store.send(.view(.didTapPicker))
                    
                case .photoItem(_, let imageSelection):
                    openImageViewer(with: imageSelection.image)
                }
            }
            .store(in: &cancellables)
        
        present(item: $store.scope(state: \.picker, action: \.scope.picker)) { [weak self] store in
            guard let self else { return UIViewController() }
            
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = store.state.selectionLimit
            configuration.filter = .images
            
            let pickerViewController = PHPickerViewController(configuration: configuration)
            pickerViewController.delegate = self
            
            return pickerViewController
        }
        
        self.contentView.sendingLetterView.letterTextView.textPublisher
            .sink { [weak self] text in
                guard let self, let text else { return }
                store.send(.view(.didEnterText(text)))
            }
            .store(in: &cancellables)
        
        contentView.letterSendingButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                
                self.navigationController?.delegate = self
                store.send(.view(.didTapSendingButton))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.configure(with: store.character)
            self.contentView.updateTextState(
                currentTextCount: store.letterText.count,
                totalTextCount: store.maxTextCount,
                state: store.textState
            )
            
            self.applySnapshot(with: store.selections)
        }
    }
}


// MARK: - Snapshot

private extension CounselingViewController {
    func initializeSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<CounselingViewSection, CounselingViewItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.selectItem(count: 0, maxCount: 10)])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func applySnapshot(with selections: [ImageSelection]) {
        var newSnapshot = NSDiffableDataSourceSnapshot<CounselingViewSection, CounselingViewItem>()
        newSnapshot.appendSections([.main])
        newSnapshot.appendItems([.selectItem(count: selections.count, maxCount: 10)])
        
        selections.forEach { selection in
            newSnapshot.appendItems([.photoItem(selection.uuid, imageSelection: selection)])
        }
        dataSource.apply(newSnapshot, animatingDifferences: true)
    }
}


// MARK: - Keyboard

private extension CounselingViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShowing = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboardShowing = false
    }
    
    private func updateContentOffset() {
        if isKeyboardShowing {
            let translateY = -self.contentView.characterGreetingLabel.frame.height - 90
            UIView.animate(withDuration: 0.25) {
                self.contentView.containerView.transform = .identity.translatedBy(x: 0, y: translateY)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.contentView.containerView.transform = .identity
            }
        }
    }
}


// MARK: - Naivation

extension CounselingViewController: CounselingPhotoCellDelegate {
    func removeSelection(_ id: UUID) {
        store.send(.view(.didRemoveSelection(id)))
    }
    
    func openImageViewer(with image: UIImage) {
        let imageViewer = ImageDetailViewController(image: image)
        imageViewer.modalPresentationStyle = .pageSheet
        present(imageViewer, animated: true)
    }
}


// MARK: - Transition

extension CounselingViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        contentView.characterImageView
    }
    
    func prepareTransition(duration: TimeInterval) async {
        await contentView.playFadeOutAllComponents(duration: duration)
    }
}

extension CounselingViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        contentView.characterImageView
    }
    
    func completeTransition(duration: TimeInterval) async {
        await contentView.playFadeInAllComponents(duration: duration)
    }
}

extension CounselingViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            contentDuration: 3.0,
            toDuration: 0.5,
            transitionContentType: .frameTransitionWithClosure(
                store.character,
                closure: sendLetter
            )
        )
    }
    
    private func sendLetter() async throws -> Session {
        let imageIDs = store.selections.compactMap { try? ImageCache.shared.saveImageToDisk(image: $0.image) }
        
        let query = Query(
            counselor: self.store.character,
            title: self.store.title,
            body: self.store.letterText,
            weather: self.store.weather,
            emoji: self.store.emoji,
            images: self.store.selections.map { $0.image },
            imageIDs: imageIDs
        )
        
        let session = try await self.counselRepository.counsel(with: query)
        
        try userSetting.update(keyPath: \.isFirstProcess, value: false)
        return session
    }
}


// MARK: - Image picker

extension CounselingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !isPickerProcessing else { return }
        isPickerProcessing = true
        
        Task {
            guard let selections = try? await loadSelections(from: results) else { return }
            store.send(.view(.didAppendImages(selections)))
            store.send(.scope(.picker(.presented(.finishSelections))))
            isPickerProcessing = false
        }
    }
    
    func loadSelections(from results: [PHPickerResult]) async throws -> [ImageSet] {
        var images: [ImageSet] = []
        
        for result in results {
            let image: UIImage? = await withCheckedContinuation { continuation in
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            
            guard let image,
                  let thumbnailImage = await image.byPreparingThumbnail(ofSize: .init(width: 300, height: 300))
            else { continue }
            
            images.append(ImageSet(image: image, thumbnailImage: thumbnailImage))
        }
        
        return images
    }
}


// MARK: - CollectionView Delegate

extension CounselingViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.item != 0 else { return [] }
        
        let item = dataSource.itemIdentifier(for: indexPath)
        if case let .photoItem(_, imageSelection) = item {
            let itemProvider = NSItemProvider()
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = imageSelection
            return [dragItem]
        }
        
        return []
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.shadowPath = UIBezierPath(rect: .zero)
        parameters.backgroundColor = .clear
        return parameters
    }
}

extension CounselingViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.shadowPath = UIBezierPath(rect: .zero)
        parameters.backgroundColor = .clear
        return parameters
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let destinationIndexPath = destinationIndexPath else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        if destinationIndexPath.item == 0 {
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        var selections = store.selections
        
        let draggedSelections = coordinator.items.compactMap { item in
            if let sourceIndexPath = item.sourceIndexPath {
                return selections[sourceIndexPath.item-1]
            }
            return nil
        }
        
        selections = selections.filter { !draggedSelections.map { $0.uuid }.contains($0.uuid) }
        
        let targetIndex = destinationIndexPath.item
        
        selections.insert(contentsOf: draggedSelections, at: targetIndex-1)
        
        self.applySnapshot(with: selections)
        store.send(.view(.didUpdateSelection(selections)))
        
        coordinator.items.forEach { item in
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
}
