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
    @IBOutlet weak var cameraView: UIView!

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.slideViewleadAnchor.constant = self.view.frame.width
        
        UIView.animate(withDuration: 0.5) {
            self.tapScanButton.alpha = 1
            self.tapToScanLabel.alpha = 1
            self.clickThePlusLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleCameraTap))
        cameraView.addGestureRecognizer(gesture)
    }

    @objc func handleCameraTap() {
        print(#function)
        let scannerViewController = ImageScannerController(delegate: self)
        scannerViewController.modalPresentationStyle = .fullScreen
        present(scannerViewController, animated: true)
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        self.slideViewleadAnchor.constant = -self.view.frame.width
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.5) {
            self.tapScanButton.alpha = 0
            self.tapToScanLabel.alpha = 0
            self.clickThePlusLabel.alpha = 0
        }
    }
}

extension ViewController: ImageScannerControllerDelegate {    
    func imageScannerController(_ scanner: ImageScannerController, didFinishBatchScanningWithResults results: [ImageScannerResults]) {
        print("\(#function) called")
        print("count = \(results.count)")
        for image in results {
            guard let scanImage = image.enhancedScan else {
                return
            }
            let image =  scanImage.image
            scanner.dismiss(animated: true)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(didPhotoSave), nil)
        }
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        print(#function)
        guard let scanImage = results.enhancedScan else {
            return
        }
        let image =  scanImage.image
        scanner.dismiss(animated: true)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didPhotoSave), nil)
    }

    @objc func didPhotoSave(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print(#function)
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        print(#function)
        scanner.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(#function)
    }
    
    
}
