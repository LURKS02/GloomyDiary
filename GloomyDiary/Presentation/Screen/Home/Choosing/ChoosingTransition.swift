//
//  ChoosingTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 9/17/24.
//

import UIKit
import Lottie

final class ChoosingTransition: NSObject { }

extension ChoosingTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 7.0
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) as? ChoosingView else { return }
        guard let toView = transitionContext.view(forKey: .to) as? CounselingView else { return }
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? ChoosingViewController else { return }
        
        guard let chosenCharacter = fromViewController.store.chosenCharacter else { return }
        let dummyView = UIImageView(image: UIImage(named: chosenCharacter.imageName))
        let imageView = UIImageView(image: UIImage(named: chosenCharacter.imageName))
        let starLottieView = LottieAnimationView(name: "stars").then {
            $0.alpha = 0.0
            $0.animationSpeed = 2.0
            $0.loopMode = .loop
            $0.contentMode = .scaleToFill
            $0.play()
        }
        let readyLabel: IntroduceLabel = IntroduceLabel().then {
            $0.text = chosenCharacter.counselReadyMessage
            $0.alpha = 0
        }
        
        guard let frame = fromViewController.getCharacterFrame() else { return }
        fromViewController.contentView.addSubview(dummyView)
        dummyView.frame = frame
        imageView.frame = frame
        
        containerView.addSubview(fromView)
        fromView.removeAllComponents {
            dummyView.removeFromSuperview()
            containerView.addSubview(imageView)
            containerView.addSubview(starLottieView)
            containerView.addSubview(readyLabel)
            
            let screenWidth = UIScreen.main.bounds.width
            let starViewWidth = starLottieView.frame.width
            let starViewHeight = starLottieView.frame.height
            starLottieView.frame = .init(x: (screenWidth - 300) / 2, y: 250, width: 300, height: starViewHeight * 300 / starViewWidth)
            readyLabel.frame = .init(x: (screenWidth - readyLabel.intrinsicContentSize.width) / 2, y: 400, width: readyLabel.intrinsicContentSize.width, height: readyLabel.intrinsicContentSize.height)
            
            toView.alpha = 0.0
            containerView.addSubview(toView)
            toView.layoutIfNeeded()
            let afterFrame = toView.characterImageView.frame
            
            UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1) {
                    let imageViewWidth = imageView.frame.width
                    let imageViewHeight = imageView.frame.height
                    
                    let targetX = (screenWidth - imageViewWidth) / 2
                    let targetY: CGFloat = 300
                    
                    imageView.frame = .init(x: targetX, y: targetY, width: imageViewWidth, height: imageViewHeight)
                    imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.05) {
                    starLottieView.alpha = 1.0
                    readyLabel.alpha = 1.0
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.7) {
                    
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.85, relativeDuration: 0.05) {
                    starLottieView.alpha = 0.0
                    readyLabel.alpha = 0.0
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                    imageView.transform = .identity
                    imageView.frame = afterFrame
                }
                
            }, completion: {
                transitionContext.completeTransition($0)
                
                starLottieView.removeFromSuperview()
                readyLabel.removeFromSuperview()
                imageView.removeFromSuperview()
                
                toView.alpha = 1.0
                toView.showAllComponents()
            })
        }
    }
}
