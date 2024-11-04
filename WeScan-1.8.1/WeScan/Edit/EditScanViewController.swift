//
//  EditScanViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation

/// The `EditScanViewController` offers an interface for the user to edit the detected quadrilateral.
final class EditScanViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.backgroundColor = .yellow
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()
    
    private lazy var nextButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.edit.button.next", tableName: nil, bundle: Bundle(for: EditScanViewController.self), value: "Next", comment: "A generic next button")
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(pushReviewController))
        button.tintColor = .white//navigationController?.navigationBar.tintColor
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.scanning.cancel", tableName: nil, bundle: Bundle(for: EditScanViewController.self), value: "Cancel", comment: "A generic cancel button")
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(cancelButtonTapped))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    
    var segment1WidthConstraint = NSLayoutConstraint()
    var imageView1TopConstraint = NSLayoutConstraint()
    var label1TopConstraint = NSLayoutConstraint()
    
    private lazy var lowerView: UIView = {
        let view = UIView()
        view.backgroundColor = .violet
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - segment1
        let segment1 = UIView()
//        segment1.backgroundColor = .gray
        segment1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment1)
        segment1WidthConstraint = segment1.widthAnchor.constraint(equalToConstant: 0)
        let segment1Constraints = [
            segment1.topAnchor.constraint(equalTo: view.topAnchor),
            segment1.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segment1.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            segment1WidthConstraint
        ]
        
        var imageView1 = UIImageView()
        if #available(iOS 13.0, *) {
            imageView1.image = UIImage(named: "crop", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
//        imageView1.backgroundColor = .cyan
        imageView1.translatesAutoresizingMaskIntoConstraints = false
        segment1.addSubview(imageView1)
        imageView1TopConstraint = imageView1.topAnchor.constraint(equalTo: segment1.topAnchor, constant: 0)
        let imageView1Constraints = [
            imageView1.heightAnchor.constraint(equalTo: segment1.heightAnchor, multiplier: 25/106),
            imageView1.widthAnchor.constraint(equalTo: imageView1.heightAnchor),
            imageView1.centerXAnchor.constraint(equalTo: segment1.centerXAnchor),
            imageView1TopConstraint
        ]
        
        let label1 = UILabel()
        label1.text = "Crop"
        label1.textColor = .white
        label1.font = UIFont(name: "Roboto-Regular", size: 12)
        label1.translatesAutoresizingMaskIntoConstraints = false
        segment1.addSubview(label1)
        label1TopConstraint = label1.topAnchor.constraint(equalTo: imageView1.bottomAnchor, constant: 0)
        let label1Constraints = [
            label1.centerXAnchor.constraint(equalTo: segment1.centerXAnchor),
            label1TopConstraint
        ]
        NSLayoutConstraint.activate(segment1Constraints + imageView1Constraints + label1Constraints)
        
        // MARK: - segment2
        let segment2 = UIView()
//        segment2.backgroundColor = .gray
        segment2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment2)
        let segment2Constraints = [
            segment2.topAnchor.constraint(equalTo: view.topAnchor),
            segment2.leadingAnchor.constraint(equalTo: segment1.trailingAnchor),
            segment2.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            segment2.widthAnchor.constraint(equalTo: segment1.widthAnchor)
        ]
        
        let imageView2 = UIImageView()
        if #available(iOS 13.0, *) {
            imageView2.image = UIImage(named: "filter", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
//        imageView2.backgroundColor = .cyan
        imageView2.translatesAutoresizingMaskIntoConstraints = false
        segment2.addSubview(imageView2)
        let imageView2Constraints = [
            imageView2.heightAnchor.constraint(equalTo: segment2.heightAnchor, multiplier: 25/106),
            imageView2.widthAnchor.constraint(equalTo: imageView2.heightAnchor),
            imageView2.centerXAnchor.constraint(equalTo: segment2.centerXAnchor),
            imageView2.topAnchor.constraint(equalTo: imageView1.topAnchor)
        ]
        
        let label2 = UILabel()
        label2.text = "Filter"
        label2.textColor = .white
        label2.font = UIFont(name: "Roboto-Regular", size: 12)
        label2.translatesAutoresizingMaskIntoConstraints = false
        segment2.addSubview(label2)
        let label2Constraints = [
            label2.centerXAnchor.constraint(equalTo: segment2.centerXAnchor),
            label2.topAnchor.constraint(equalTo: label1.topAnchor)
        ]
        NSLayoutConstraint.activate(segment2Constraints + imageView2Constraints + label2Constraints)
        
        // MARK: - segment3
        let segment3 = UIView()
//        segment3.backgroundColor = .gray
        segment3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment3)
        let segment3Constraints = [
            segment3.topAnchor.constraint(equalTo: view.topAnchor),
            segment3.leadingAnchor.constraint(equalTo: segment2.trailingAnchor),
            segment3.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            segment3.widthAnchor.constraint(equalTo: segment2.widthAnchor)
        ]
        
        let imageView3 = UIImageView()
        if #available(iOS 13.0, *) {
            imageView3.image = UIImage(named: "draw", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
//        imageView3.backgroundColor = .cyan
        imageView3.translatesAutoresizingMaskIntoConstraints = false
        segment3.addSubview(imageView3)
        let imageView3Constraints = [
            imageView3.heightAnchor.constraint(equalTo: segment3.heightAnchor, multiplier: 25/106),
            imageView3.widthAnchor.constraint(equalTo: imageView3.heightAnchor),
            imageView3.centerXAnchor.constraint(equalTo: segment3.centerXAnchor),
            imageView3.topAnchor.constraint(equalTo: imageView2.topAnchor)
        ]
        
        let label3 = UILabel()
        label3.text = "Draw"
        label3.textColor = .white
        label3.font = UIFont(name: "Roboto-Regular", size: 12)
        label3.translatesAutoresizingMaskIntoConstraints = false
        segment3.addSubview(label3)
        let label3Constraints = [
            label3.centerXAnchor.constraint(equalTo: segment3.centerXAnchor),
            label3.topAnchor.constraint(equalTo: label2.topAnchor)
        ]
        NSLayoutConstraint.activate(segment3Constraints + imageView3Constraints + label3Constraints)
        
        //---------------segment 4
        let segment4 = UIView()
//        segment4.backgroundColor = .gray
        segment4.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment4)
        let segment4Constraints = [
            segment4.topAnchor.constraint(equalTo: view.topAnchor),
            segment4.leadingAnchor.constraint(equalTo: segment3.trailingAnchor),
            segment4.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            segment4.widthAnchor.constraint(equalTo: segment3.widthAnchor)
        ]
        
        let imageView4 = UIImageView()
        if #available(iOS 13.0, *) {
            imageView4.image = UIImage(named: "signature", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
//        imageView4.backgroundColor = .cyan
        imageView4.translatesAutoresizingMaskIntoConstraints = false
        segment4.addSubview(imageView4)
        let imageView4Constraints = [
            imageView4.heightAnchor.constraint(equalTo: segment4.heightAnchor, multiplier: 25/106),
            imageView4.widthAnchor.constraint(equalTo: imageView4.heightAnchor),
            imageView4.centerXAnchor.constraint(equalTo: segment4.centerXAnchor),
            imageView4.topAnchor.constraint(equalTo: imageView3.topAnchor)
        ]
        
        let label4 = UILabel()
        label4.text = "Signature"
        label4.textColor = .white
        label4.font = UIFont(name: "Roboto-Regular", size: 12)
        label4.translatesAutoresizingMaskIntoConstraints = false
        segment4.addSubview(label4)
        let label4Constraints = [
            label4.centerXAnchor.constraint(equalTo: segment4.centerXAnchor),
            label4.topAnchor.constraint(equalTo: label3.topAnchor)
        ]
        NSLayoutConstraint.activate(segment4Constraints + imageView4Constraints + label4Constraints)

        return view
    }()
    
    /// The image the quadrilateral was detected on.
    private let image: UIImage
    
    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quad: Quadrilateral
    
    private var zoomGestureController: ZoomGestureController!
    
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    
    // MARK: - Life Cycle
    
    init(image: UIImage, quad: Quadrilateral?, rotateImage: Bool = true) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.quad = quad ?? EditScanViewController.defaultQuad(forImage: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        title = NSLocalizedString("wescan.edit.title", tableName: nil, bundle: Bundle(for: EditScanViewController.self), value: "Edit Scan", comment: "The title of the EditScanViewController")
        navigationItem.rightBarButtonItem = nextButton
        if let firstVC = self.navigationController?.viewControllers.first, firstVC == self {
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
        adjustLowerViewConstraints()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Work around for an iOS 11.2 bug where UIBarButtonItems don't get back to their normal state after being pressed.
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(quadView)
        view.addSubview(lowerView)
        view.backgroundColor = .cyan
    }
    
    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: lowerView.topAnchor, constant: -20),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]
        
        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)
        
        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]
        
        let lowerViewConstraints = [
            lowerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lowerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lowerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (106/932))
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints + imageViewConstraints + lowerViewConstraints)
    }
    
    // MARK: - Actions
    @objc func cancelButtonTapped() {
        if let imageScannerController = navigationController as? ImageScannerController {
            imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
        }
    }
    
    @objc func pushReviewController() {
        guard let quad = quadView.quad,
            let ciImage = CIImage(image: image) else {
                if let imageScannerController = navigationController as? ImageScannerController {
                    let error = ImageScannerControllerError.ciImageCreation
                    imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
                }
                return
        }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad
        
        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        
        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScannerScan(image: $0) }
        
        let results = ImageScannerResults(detectedRectangle: scaledQuad, originalScan: ImageScannerScan(image: image), croppedScan: ImageScannerScan(image: croppedImage), enhancedScan: enhancedScan)
        
        let reviewViewController = ReviewViewController(results: results)
        navigationController?.pushViewController(reviewViewController, animated: true)
    }
    
    private func displayQuad() {
        let imageSize = image.size
        let imageFrame = CGRect(origin: quadView.frame.origin, size: CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant))
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }
    
    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time, we adjust the constraints to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }
    
    private func adjustLowerViewConstraints() {
        segment1WidthConstraint.constant = lowerView.frame.width/4
        imageView1TopConstraint.constant = lowerView.frame.height * (20/106)
        label1TopConstraint.constant = lowerView.frame.height * (10/106)
    }
    
    /// Generates a `Quadrilateral` object that's centered and 90% of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.05)
        let topRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.05)
        let bottomRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.95)
        let bottomLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.95)
        
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        
        return quad
    }
    
}

