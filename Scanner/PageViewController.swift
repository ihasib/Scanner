//
//  PageViewController.swift
//  Scanner
//
//  Created by S. M. Hasibur Rahman on 3/9/24.
//

import UIKit
//https://tobyliu-sw.medium.com/uiscrollview-part-2-paging-enabled-with-uipagecontrol-937619a0c57d
class PageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        print(#function)
//        print(sender.)
        let pageSize: CGSize = self.scrollView.bounds.size
        let pageOrigin: CGPoint = CGPoint(x: CGFloat(sender.currentPage) * pageSize.width, y: 0.0)
        
        // Scroll to corresponding page when current page index of page control is changed
        self.scrollView.scrollRectToVisible(CGRect(origin: pageOrigin, size: pageSize), animated: true)
    }
}
