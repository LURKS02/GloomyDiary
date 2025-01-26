//
//  CounselingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import ComposableArchitecture
import PhotosUI
import UIKit

final class CounselingViewController: BaseViewController<CounselingView> {
    
    let store: StoreOf<Counseling>
    
    @Dependency(\.counselRepository) var counselRepository
    @Dependency(\.userSetting) var userSetting
    @Dependency(\.logger) var logger
    
    
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
            
        case .photoItem(_, let imageID):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CounselingPhotoCollectionViewCell.identifier,
                for: indexPath
            ) as? CounselingPhotoCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configure(with: imageID, delegate: self)
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
        
        self.navigationItem.hidesBackButton = true
        contentView.tapGesture.addTarget(self, action: #selector(viewTouched))
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
    }
    
    
    // MARK: - Touch Cycle
    
    @objc func viewTouched() {
        self.contentView.sendingLetterView.endEditing(true)
    }
}


// MARK: - bind

private extension CounselingViewController {
    private func bind() {
        contentView.photoCollectionView.delegate = self
        contentView.photoCollectionView.dragDelegate = self
        contentView.photoCollectionView.dropDelegate = self
        
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
        
        contentView.sendingLetterView.validationSubject
            .subscribe(onNext: { [weak self] validation in
                self?.contentView.letterSendingButton.isEnabled = validation
            })
            .disposed(by: rx.disposeBag)
        
        contentView.letterSendingButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.letterSendingButton.title(for: .normal) else { return }
                self?.logger.send(.tapped, title, nil)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                navigateToResult(with: store.character)
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.configure(with: store.character)
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
    
    func applySnapshot(with items: [CounselingViewItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<CounselingViewSection, CounselingViewItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.selectItem(count: items.count, maxCount: 10)])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
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

extension CounselingViewController {
    func navigateToResult(with character: CounselingCharacter) {
        let store: StoreOf<CounselResult> = Store(initialState: .init(
            character: character,
            request: self.contentView.sendingLetterView.letterTextView.text
        ), reducer: { CounselResult() })
        let resultViewController = ResultViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(resultViewController,
                                                 animated: true)
    }
}

extension CounselingViewController: CounselingPhotoCellDelegate {
    func removeImage(_ id: UUID) {
        let items = dataSource.snapshot().itemIdentifiers
        let filteredItems = items.compactMap { item -> CounselingViewItem? in
            if case let .photoItem(_, photoID) = item, photoID == id {
                return nil
            } else if case .photoItem = item {
                return item
            }
            return nil
        }
        
        applySnapshot(with: filteredItems)
            
        store.send(.updateImageIDs(filteredItems.compactMap { item -> UUID? in
            if case let .photoItem(_, imageID) = item {
                return imageID
            }
            return nil
        }))
    }
    
    func openImageViewer(with id: UUID) {
        let imageViewer = ImageDetailViewController(imageID: id)
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
        AnimatedTransition(fromDuration: 0.5,
                           contentDuration: 3.0,
                           toDuration: 0.5,
                           transitionContentType: .frameTransitionWithClosure(store.character, closure: sendLetter))
    }
    
    private func sendLetter() async throws -> String {
        guard let Weather = Weather(identifier: self.store.weatherIdentifier),
              let Emoji = Emoji(identifier: self.store.emojiIdentifier) else {
            throw LocalError(message: "Session Error")
        }
        
        let result = try await self.counselRepository.counsel(
            to: self.store.character,
            title: self.store.title,
            userInput: self.contentView.sendingLetterView.letterTextView.text,
            weather: Weather,
            emoji: Emoji,
            imageIDs: self.store.imageIDs
        )
        try userSetting.update(keyPath: \.isFirstProcess, value: false)
        return result
    }
}


// MARK: - Image picker

extension CounselingViewController: PHPickerViewControllerDelegate {
    func openPicker() {
        guard store.imageIDs.count < 10 else { return }
        var pickerConfiguration = PHPickerConfiguration()
        let numberOfItems = dataSource.snapshot().numberOfItems
        pickerConfiguration.selectionLimit = 10 - numberOfItems + 1
        pickerConfiguration.filter = .images
        let picker = PHPickerViewController(configuration: pickerConfiguration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !isPickerProcessing else { return }
        isPickerProcessing = true
        
        Task {
            guard let ids = try? await loadImageIDs(from: results) else { return }
            let snapshot = dataSource.snapshot()
            var items = snapshot.itemIdentifiers
            items.append(contentsOf: ids.map { CounselingViewItem.photoItem(UUID(), imageID: $0) })
            items.removeFirst()
            applySnapshot(with: items)
            picker.dismiss(animated: true)
            isPickerProcessing = false
            
            store.send(.selectedImageIDs(ids))
        }
    }
    
    func loadImageIDs(from results: [PHPickerResult]) async throws -> [UUID] {
        var imageIDs: [UUID] = []
        
        for result in results {
            let image = try await loadUIImage(from: result)
            let imageID = try ImageCache.shared.saveImageToDisk(image: image)
            imageIDs.append(imageID)
        }
        
        return imageIDs
    }
    
    func loadUIImage(from result: PHPickerResult) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let image = object as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: LocalError(message: "Data load error"))
                }
            }
        }
    }
}


// MARK: - CollectionView Delegate

extension CounselingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let items = snapshot.itemIdentifiers
        let selectedItem = items[indexPath.row]
        
        if case .selectItem = selectedItem {
            openPicker()
        }
    }
}

extension CounselingViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.item != 0 else { return [] }
        
        let item = dataSource.itemIdentifier(for: indexPath)
        if case let .photoItem(_, image) = item {
            let itemProvider = NSItemProvider()
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = image
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
        var snapshot = dataSource.snapshot()
        
        let draggedItems = coordinator.items.compactMap { item in
            if let sourceIndexPath = item.sourceIndexPath {
                return snapshot.itemIdentifiers[sourceIndexPath.item]
            }
            return nil
        }
        
        snapshot.deleteItems(draggedItems)
        let targetIndex = destinationIndexPath.item
        let currentItems = snapshot.itemIdentifiers
        var updatedItems = currentItems
        updatedItems.insert(contentsOf: draggedItems, at: targetIndex)
        updatedItems.removeFirst()
        
        applySnapshot(with: updatedItems)
        
        coordinator.items.forEach { item in
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
        
        store.send(.updateImageIDs(updatedItems.compactMap { item -> UUID? in
            if case let .photoItem(_, imageID) = item {
                return imageID
            }
            return nil
        }))
    }
}
