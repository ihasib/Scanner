//
//  ScannerViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//
//  swiftlint:disable line_length

import AVFoundation
import UIKit

/// The `ScannerViewController` offers an interface to give feedback to the user regarding quadrilaterals that are detected. It also gives the user the opportunity to capture an image with a detected rectangle.
public final class ScannerViewController: UIViewController {

    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()

    /// The view that shows the focus rectangle (when the user taps to focus, similar to the Camera app)
    private var focusRectangle: FocusRectangleView!

    /// The view that draws the detected rectangles.
    private let quadView = QuadrilateralView()

    /// Whether flash is enabled
    private var flashEnabled = false

    /// The original bar style that was set by the host app
    private var originalBarStyle: UIBarStyle?
    static var batchResult = [ImageScannerResults]()
    
    private lazy var customNavigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var previewView: UIView = {
        let view = UIView()
//        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var popupTop: UIView = {
        let view = UIView()
        view.backgroundColor = .violet.withAlphaComponent(0.7)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        var image = UIImage(named: "warning")
        if #available(iOS 13.0, *) {
            image = UIImage(named: "warning", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        let label = UILabel()
        label.text = "Please move closer"
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    private lazy var popupBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .violet.withAlphaComponent(0.7)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let titlelabel = UILabel()
        titlelabel.text = "Scan Your Document"
        view.addSubview(titlelabel)
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        titlelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titlelabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        
        let descriptionlabel = UILabel()
        descriptionlabel.text = "Center the document on the screen. A box might appear to help with adjustments"
        descriptionlabel.font = UIFont.systemFont(ofSize: 12)
        descriptionlabel.numberOfLines = 0
        descriptionlabel.textAlignment = .center
        view.addSubview(descriptionlabel)
        descriptionlabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionlabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionlabel.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 5).isActive = true
        descriptionlabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        
        
        var image = UIImage(named: "doc")
        if #available(iOS 13.0, *) {
            image = UIImage(named: "doc", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: descriptionlabel.bottomAnchor, constant: 2).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (60/232)).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        let button = UIButton()
        button.setTitle("Got it!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(gotItButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (27/232)).isActive = true
        button.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: (27/68)).isActive = true
        
        return view
    }()

    private lazy var lowerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shutterButton: ShutterButton = {
        let button = ShutterButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var batchShowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(batchShowTapped))
        view.addGestureRecognizer(gesture)
        
        return view
    }()
    
    private lazy var batchShowThumb: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pic"))
        imageView.backgroundColor = .cyan
        batchShowView.addSubview(imageView)
        batchShowView.bringSubviewToFront(badgeLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.bottomAnchor.constraint(equalTo: batchShowView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: batchShowView.leadingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: batchShowView.heightAnchor, multiplier: 0.9).isActive = true
        imageView.widthAnchor.constraint(equalTo: batchShowView.widthAnchor, multiplier: 0.9).isActive = true
        return imageView
    }()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "4"
        label.textColor = .black
        label.backgroundColor = .yellow
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        batchShowView.addSubview(label)
        

        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: batchShowView.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: batchShowView.trailingAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: batchShowView.heightAnchor, multiplier: 0.3).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor).isActive = true
        label.layer.masksToBounds = true
        label.layer.cornerRadius =  3
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("wescan.scanning.cancel", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Cancel", comment: "The cancel button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        return button
    }()

    private lazy var autoScanButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.scanning.auto", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Auto", comment: "The auto button state")
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(toggleAutoScan))
        button.tintColor = .white

        return button
    }()

    private lazy var flashButton: UIBarButtonItem = {
        let image = UIImage(systemName: "bolt.fill", named: "flash", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleFlash))
        button.tintColor = .white

        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    // MARK: - Life Cycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        title = nil
        view.backgroundColor = UIColor.black

        setupViews()
        setupNavigationBar2()
        setupConstraints()

        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer, delegate: self)

        originalBarStyle = navigationController?.navigationBar.barStyle

        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        CaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true

        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        navigationController?.navigationBar.backgroundColor = .white
        badgeLabel.text = "4"
        if #available(iOS 13.0, *) {
            batchShowThumb.image =  UIImage(named: "pic", in: Bundle.main, with: nil)
        } else {
            // Fallback on earlier versions
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoPreviewLayer.frame = previewView.layer.bounds
        
        shutterButton.topAnchor.constraint(equalTo: lowerView.topAnchor, constant: lowerView.frame.height * (35/176)).isActive = true
        batchShowView.trailingAnchor.constraint(equalTo: lowerView.trailingAnchor, constant: -lowerView.frame.width * (21/430)).isActive = true
        
        popupTop.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: previewView.frame.height * (18/642)).isActive = true
        popupTop.widthAnchor.constraint(equalToConstant: previewView.frame.width * (378/430)).isActive = true
        popupTop.heightAnchor.constraint(equalToConstant: previewView.frame.height * (38/642)).isActive = true
        
        popupBottom.topAnchor.constraint(equalTo: previewView.topAnchor, constant: previewView.frame.height * (390/642)).isActive = true
        popupBottom.widthAnchor.constraint(equalToConstant: previewView.frame.width * (389/430)).isActive = true
        popupBottom.heightAnchor.constraint(equalToConstant: previewView.frame.height * (232/642)).isActive = true
        view.layoutIfNeeded()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = originalBarStyle ?? .default
        captureSessionManager?.stop()
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }

    // MARK: - Setups

    private func setupViews() {
        view.backgroundColor = .darkGray
        previewView.layer.addSublayer(videoPreviewLayer)
        previewView.addSubview(popupTop)
        previewView.addSubview(popupBottom)
        
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        view.addSubview(quadView)
        view.addSubview(previewView)
        
        view.addSubview(lowerView)
        lowerView.addSubview(shutterButton)
        lowerView.addSubview(batchShowView)
//        view.addSubview(activityIndicator)
    }

    private func setupNavigationBar() {
        navigationItem.setLeftBarButton(flashButton, animated: false)
        navigationItem.setRightBarButton(autoScanButton, animated: false)

        if UIImagePickerController.isFlashAvailable(for: .rear) == false {
            let flashOffImage = UIImage(systemName: "bolt.slash.fill", named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
            flashButton.image = flashOffImage
            flashButton.tintColor = UIColor.lightGray
        }
    }
    
    private func setupNavigationBar2() {
        view.addSubview(customNavigationBar)
        var customNavigationBarConstraints = [NSLayoutConstraint]()
        customNavigationBarConstraints = [
            customNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customNavigationBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            customNavigationBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (77/932))
        ]
        

        NSLayoutConstraint.activate(customNavigationBarConstraints)
    }

    private func setupConstraints() {
        var quadViewConstraints = [NSLayoutConstraint]()
        var previewViewConstraints = [NSLayoutConstraint]()
        var popupTopConstraints = [NSLayoutConstraint]()
        var popupBottomConstraints = [NSLayoutConstraint]()
        var shutterButtonConstraints = [NSLayoutConstraint]()
        var batchShowViewConstraints = [NSLayoutConstraint]()
        var activityIndicatorConstraints = [NSLayoutConstraint]()
        var lowerViewConstraints = [NSLayoutConstraint]()
        
        popupTopConstraints = [
            popupTop.centerXAnchor.constraint(equalTo: previewView.centerXAnchor)
        ]
        
        popupBottomConstraints = [
            popupBottom.centerXAnchor.constraint(equalTo: previewView.centerXAnchor)
        ]
        
        previewViewConstraints = [
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: lowerView.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
            quadView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]

        batchShowViewConstraints = [
            batchShowView.heightAnchor.constraint(equalTo: lowerView.heightAnchor, multiplier: (70/176)),
            batchShowView.widthAnchor.constraint(equalTo: batchShowView.heightAnchor),
            batchShowView.topAnchor.constraint(equalTo: shutterButton.topAnchor)
        ]

        activityIndicatorConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        lowerViewConstraints = [
            lowerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lowerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lowerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (176/932))
        ]
        
        shutterButtonConstraints = [
            shutterButton.centerXAnchor.constraint(equalTo: lowerView.centerXAnchor),
            shutterButton.heightAnchor.constraint(equalTo: lowerView.heightAnchor, multiplier: (90/176)),
            shutterButton.widthAnchor.constraint(equalTo: shutterButton.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(previewViewConstraints + popupTopConstraints + popupBottomConstraints + lowerViewConstraints + batchShowViewConstraints + shutterButtonConstraints)
    }

    // MARK: - Tap to Focus

    /// Called when the AVCaptureDevice detects that the subject area has changed significantly. When it's called, we reset the focus so the camera is no longer out of focus.
    @objc private func subjectAreaDidChange() {
        /// Reset the focus and exposure back to automatic
        do {
            try CaptureSession.current.resetFocusToAuto()
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }

        /// Remove the focus rectangle if one exists
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: true)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard  let touch = touches.first else { return }
        let touchPoint = touch.location(in: view)
        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)

        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)

        focusRectangle = FocusRectangleView(touchPoint: touchPoint)
        previewView.addSubview(focusRectangle)

        do {
            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
    }

    // MARK: - Actions

    @objc private func captureImage(_ sender: UIButton) {
        (navigationController as? ImageScannerController)?.flashToBlack()
        shutterButton.isUserInteractionEnabled = false
        captureSessionManager?.capturePhoto()

    }

    @objc private func toggleAutoScan() {
        if CaptureSession.current.isAutoScanEnabled {
            CaptureSession.current.isAutoScanEnabled = false
            autoScanButton.title = NSLocalizedString("wescan.scanning.manual", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Manual", comment: "The manual button state")
        } else {
            CaptureSession.current.isAutoScanEnabled = true
            autoScanButton.title = NSLocalizedString("wescan.scanning.auto", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Auto", comment: "The auto button state")
        }
    }

    @objc private func toggleFlash() {
        let state = CaptureSession.current.toggleFlash()

        let flashImage = UIImage(systemName: "bolt.fill", named: "flash", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let flashOffImage = UIImage(systemName: "bolt.slash.fill", named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)

        switch state {
        case .on:
            flashEnabled = true
            flashButton.image = flashImage
            flashButton.tintColor = .yellow
        case .off:
            flashEnabled = false
            flashButton.image = flashImage
            flashButton.tintColor = .white
        case .unknown, .unavailable:
            flashEnabled = false
            flashButton.image = flashOffImage
            flashButton.tintColor = UIColor.lightGray
        }
    }
    
    @objc private func gotItButtonTapped() {
        popupTop.isHidden = true
        popupBottom.isHidden = true
    }

    @objc private func cancelImageScannerController() {
        if ScannerViewController.batchResult.count > 0 {
            showSwitchPopup() {
//                ScannerViewController.isBatchEnabled = true
                self.resetBatchStates()
                self.dismissVC()
            }
            return
        }
        dismissVC()
    }
    
    private func dismissVC() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        resetBatchStates()
        imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
    }
    
    private func resetBatchStates() {
        ScannerViewController.batchResult = []
        saveButton.isHidden = true
    }
    
    @objc private func saveButtonTapped() {
        save()
    }
    
    private func save() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFinishBatchScanningWithResults: ScannerViewController.batchResult)
    }
    
    private func showSwitchPopup(completion: @escaping () -> () ) {
        let alert = UIAlertController(title: "Want to dismiss batch scan?", message: "Press YES to dismiss.\nPress NO to continue Batch scan.", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "NO", style: .cancel) { _ in
            //no operation
        }
        
        let alertAction2 = UIAlertAction(title: "YES", style: .default) { _ in
            completion()
        }
        alert.addAction(alertAction)
        alert.addAction(alertAction2)
        
        present(alert, animated: true)
    }
    
    private func showSavePopup() {
        let alert = UIAlertController(title: "Want to Save?", message: "Press SAVE to preserve scan.\nPress DISCARD to abandon scan.", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "SAVE", style: .default) { _ in
            self.save()
        }
        
        let alertAction2 = UIAlertAction(title: "DISCARD", style: .cancel) { _ in
            self.dismissVC()
        }
        alert.addAction(alertAction)
        alert.addAction(alertAction2)
        
        present(alert, animated: true)
    }

    @objc private func batchShowTapped() {
        print("\(#function) called")

        let editVC = TablePageViewController(nibName: "TablePageViewController", bundle: Bundle.module)
        navigationController?.pushViewController(editVC, animated: false)
    }
}

extension ScannerViewController: RectangleDetectionDelegateProtocol {
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {

        activityIndicator.stopAnimating()
        shutterButton.isUserInteractionEnabled = true

        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
    }

    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        activityIndicator.startAnimating()
        captureSessionManager.stop()
        shutterButton.isUserInteractionEnabled = false
    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: Quadrilateral?) {
        activityIndicator.stopAnimating()

        let editVC = EditScanViewController(image: picture, quad: quad)
        navigationController?.pushViewController(editVC, animated: false)

        shutterButton.isUserInteractionEnabled = true
    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, _ imageSize: CGSize) {
        guard let quad = quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            quadView.removeQuadrilateral()
            return
        }

        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)

        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)

        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)

        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)

        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)

        let transforms = [scaleTransform, rotationTransform, translationTransform]

        let transformedQuad = quad.applyTransforms(transforms)

        quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
    }

}
