//
//  ViewController.swift
//  Scanner
//
//  Created by S. M. Hasibur Rahman on 21/8/24.
//

import UIKit
import WeScan

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        let scannerViewController = ImageScannerController(delegate: self)
        scannerViewController.modalPresentationStyle = .fullScreen
        present(scannerViewController, animated: true)
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
