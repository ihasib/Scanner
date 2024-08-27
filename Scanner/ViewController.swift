//
//  ViewController.swift
//  Scanner
//
//  Created by S. M. Hasibur Rahman on 21/8/24.
//

import UIKit
import WeScan

class ViewController: UIViewController {

    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var slideViewleadAnchor: NSLayoutConstraint!
    @IBOutlet weak var tapScanButton: UIButton!
    @IBOutlet weak var tapToScanLabel: UILabel!
    @IBOutlet weak var clickThePlusLabel: UILabel!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.slideViewleadAnchor.constant = self.view.frame.width
        
        UIView.animate(withDuration: 1) {
            self.tapScanButton.alpha = 1
            self.tapToScanLabel.alpha = 1
            self.clickThePlusLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        self.slideViewleadAnchor.constant = -self.view.frame.width
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 1) {
            self.tapScanButton.alpha = 0
            self.tapToScanLabel.alpha = 0
            self.clickThePlusLabel.alpha = 0
        }
//        let scannerViewController = ImageScannerController(delegate: self)
//        scannerViewController.modalPresentationStyle = .fullScreen
//        present(scannerViewController, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        print(#function)
    }
    
}

extension ViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        print(#function)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        print(#function)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(#function)
    }
    
    
}
