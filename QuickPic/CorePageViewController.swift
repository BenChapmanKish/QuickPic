//
//  CorePageViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-17.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

class CorePageViewController: UIPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([self.orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
        
        // TODO: pick an app-wide background colour and make it a constant
        self.view.backgroundColor = .white
    }
    
    // Update background colors
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
        
        guard let viewController = viewControllers?.first else {
            return
        }
        
        self.view.backgroundColor = viewController.view.backgroundColor
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let storyboard = UIStoryboard(name: Ids.Identifiers.mainStoryboard, bundle: nil)
        return [
            storyboard.instantiateViewController(withIdentifier: Ids.Identifiers.inboxVC),
            storyboard.instantiateViewController(withIdentifier: Ids.Identifiers.cameraVC),
            storyboard.instantiateViewController(withIdentifier: Ids.Identifiers.profileVC)
        ]
    }()

}


extension CorePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 && previousIndex < self.orderedViewControllers.count else {
            return nil
        }
        
        return self.orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex >= 0 && nextIndex < self.orderedViewControllers.count else {
            return nil
        }
        
        return self.orderedViewControllers[nextIndex]
    }
}

extension CorePageViewController: UIPageViewControllerDelegate {
    // Update background colors
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed,
            let viewController = pageViewController.viewControllers?.last else { return }
        
        self.view.backgroundColor = viewController.view.backgroundColor
    }
}
