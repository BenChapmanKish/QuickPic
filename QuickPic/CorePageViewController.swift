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
        
        self.setViewControllers([self.orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
        
        // TODO: pick an app-wide background colour and make it a constant
        self.view.backgroundColor = .white

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            UIStoryboard(name: Ids.Identifiers.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: Ids.Identifiers.inboxVC),
            UIStoryboard(name: Ids.Identifiers.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: Ids.Identifiers.cameraVC),
            UIStoryboard(name: Ids.Identifiers.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: Ids.Identifiers.profileVC)
        ]
    }()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CorePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0,
            self.orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return self.orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = self.orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex,
            orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return self.orderedViewControllers[nextIndex]
    }
}
