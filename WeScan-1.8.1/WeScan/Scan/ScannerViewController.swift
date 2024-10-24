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
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        var image: UIImage!
        if #available(iOS 13.0, *) {
//            image = UIImage(s)
            image = UIImage(named: "back", in: Bundle.module, compatibleWith: nil)
        } else {
            // Fallback on earlier versions
        }
        var button = UIButton()
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
//        button.tintColor = .violet
        button.contentMode = .scaleAspectFit
//        button.backgroundColor = .cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var captureOptionButton: UIButton = {
        var image = UIImage(named: "captureOptions")
        if #available(iOS 13.0, *) {
            image = UIImage(named: "captureOptions", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
        var button = UIButton()
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
//        button.tintColor = .violet
//        button.backgroundColor = .cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var flashButton2: UIButton = {
        var image = UIImage(named: "flash4")
        if #available(iOS 13.0, *) {
            image = UIImage(named: "flash4", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
        var button = UIButton()
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
//        button.tintColor = .violet
//        button.backgroundColor = .cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var autoScanButton2: UIView = {
        var image = UIImage(named: "autoManualSwitch")
        if #available(iOS 13.0, *) {
            image = UIImage(named: "autoManualSwitch", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
        //----
        var label = UILabel()
        label.text = "Auto Capture"
        label.font = UIFont(name: "Roboto-Medium", size: 16)
        label.textColor = .violet
        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        
        var imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addSubview(imageView)
        
//        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: (17.8/184)).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: (20/17.8)).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        view.backgroundColor = .cyan
        return view
//        imageView
        
        //---
//        var button = UIButton()
//        button.setImage(image, for: .normal)
//        button.setTitle("Auto Capture", for: .normal)
//        button.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16)
//        button.setTitleColor(.violet, for: .normal) // Set the title color
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0) // Add some spacing between the image and text
//
//        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
////        button.tintColor = .violet
//        button.backgroundColor = .cyan
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        button.imageView?.tintColor = .violet
//        return button
    }()
    
    private lazy var doneButton: UIButton = {
        var button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.violet, for: .normal)
        button.titleLabel?.font = UIFont(name: "Inter_18pt-SemiBold", size: 18)
        
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        button.tintColor = .violet
//        button.backgroundColor = .cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        view.layer.cornerRadius = 22
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
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (15/38)).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        let label = UILabel()
        label.text = "Please move closer"
        label.textColor = .white
        label.font = UIFont(name: "Roboto-Regular", size: 16)
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
        titlelabel.textColor = .white
        titlelabel.font = UIFont(name: "Roboto-Medium", size: 16)
        titlelabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let descriptionlabel = UILabel()
        descriptionlabel.text = "Center the document on the screen. A box might appear to help with adjustments"
        descriptionlabel.font = UIFont(name: "Roboto-Regular", size: 12)
        descriptionlabel.numberOfLines = 0
        descriptionlabel.textColor = .white
        descriptionlabel.textAlignment = .center
        
        var image = UIImage(named: "doc")
        if #available(iOS 13.0, *) {
            image = UIImage(named: "doc", in: Bundle.module, with: nil)
        } else {
            // Fallback on earlier versions
        }
        let imageView = UIImageView(image: image)
        
        let button = UIButton()
        button.setTitle("Got it!", for: .normal)
//        button.titleLabel?.font = UIFont.fontNames(forFamilyName: "Roboto")
//        button.titleLabel?.font = UIFont(name: "Subhead", size: 12)
        button.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 12)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(gotItButtonTapped), for: .touchUpInside)
        
        view.addSubview(titlelabel)
        view.addSubview(descriptionlabel)
        view.addSubview(imageView)
        view.addSubview(button)
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionlabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabelConstraints = [
            titlelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let descriptionlabelConstraints = [
            descriptionlabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionlabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
            descriptionlabel.bottomAnchor.constraint(lessThanOrEqualTo: imageView.topAnchor)
        ]
        
        let imageViewConstraints = [
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (60/232)),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ]
        
        let buttonConstraints = [
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (27/232)),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: (68/27))
        ]
        
        NSLayoutConstraint.activate(titleLabelConstraints + descriptionlabelConstraints + imageViewConstraints + buttonConstraints)
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
        imageView.heightAnchor.constraint(equalTo: batchShowView.heightAnchor, multiplier: (70/77)).isActive = true
        imageView.widthAnchor.constraint(equalTo: batchShowView.widthAnchor, multiplier: (70/77)).isActive = true
        return imageView
    }()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "4"
        label.textColor = .black
        label.backgroundColor = .yellow
        label.font = UIFont(name: "Inter_18pt-SemiBold", size: 10)
        label.textAlignment = .center
        batchShowView.addSubview(label)
        

        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: batchShowView.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: batchShowView.trailingAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: batchShowView.heightAnchor, multiplier: (15/77)).isActive = true
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
        
        
        //        GUI guide says leadanchor = 20. To maintain aspect fit ration "<" image gets set within 1/2 of button width.
        //        rest half's is transparent on both side of the button. check by making button background color change.
        //        To tackle this ratio   5(transparent)+10(image)+5(transparnt)
        cancelButton.leadingAnchor.constraint(equalTo: customNavigationBar.leadingAnchor, constant: customNavigationBar.frame.width * (15/430)).isActive = true//gui guide(20/430)
        captureOptionButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: customNavigationBar.frame.width * (20/430)).isActive = true//gui guide(25/430)
        flashButton2.leadingAnchor.constraint(equalTo: captureOptionButton.trailingAnchor, constant: customNavigationBar.frame.width * (25/430)).isActive = true
        autoScanButton2.leadingAnchor.constraint(equalTo: flashButton2.trailingAnchor, constant: customNavigationBar.frame.width * (25/430)).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: autoScanButton2.trailingAnchor, constant: customNavigationBar.frame.width * (35.22/430)).isActive = true
        let label = autoScanButton2.subviews[0]
        let imageViewAuto = autoScanButton2.subviews[1]
        let autoScanButton2Width = customNavigationBar.frame.width * (184/430)
        label.trailingAnchor.constraint(equalTo: imageViewAuto.leadingAnchor, constant: autoScanButton2Width * (-20/184)).isActive = true
        
        
        shutterButton.topAnchor.constraint(equalTo: lowerView.topAnchor, constant: lowerView.frame.height * (35/176)).isActive = true
        batchShowView.trailingAnchor.constraint(equalTo: lowerView.trailingAnchor, constant: -lowerView.frame.width * (21/430)).isActive = true
        batchShowView.topAnchor.constraint(equalTo: lowerView.topAnchor, constant: lowerView.frame.height * (29/176)).isActive = true
        
        popupTop.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: previewView.frame.height * (18/642)).isActive = true
        let popupTopWidth = previewView.frame.width * (378/430)
        let popupTopHeight = previewView.frame.height * (38/642)
        popupTop.widthAnchor.constraint(equalToConstant: popupTopWidth).isActive = true
        popupTop.heightAnchor.constraint(equalToConstant: popupTopHeight).isActive = true
        let imageView = popupTop.subviews[0]
        imageView.leadingAnchor.constraint(equalTo: popupTop.leadingAnchor, constant: popupTopWidth * (18/378)).isActive = true
        
        popupBottom.topAnchor.constraint(equalTo: previewView.topAnchor, constant: previewView.frame.height * (390/642)).isActive = true
        popupBottom.widthAnchor.constraint(equalToConstant: previewView.frame.width * (389/430)).isActive = true
        popupBottom.heightAnchor.constraint(equalToConstant: previewView.frame.height * (232/642)).isActive = true
        
        
        
        let popupBottomHeight = previewView.frame.height * (232/642)
        let titleLabel = popupBottom.subviews[0]
        let descriptionLabel = popupBottom.subviews[1]
        let docImageView = popupBottom.subviews[2]
        let gotItButton = popupBottom.subviews[3]

        titleLabel.topAnchor.constraint(equalTo: popupBottom.topAnchor, constant: popupBottomHeight * (20/232)).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: popupBottomHeight * (16/232)).isActive = true
        docImageView.bottomAnchor.constraint(equalTo: gotItButton.topAnchor, constant: popupBottomHeight * (-20/232)).isActive = true
        gotItButton.bottomAnchor.constraint(equalTo: popupBottom.bottomAnchor, constant: popupBottomHeight * (-25/232)).isActive = true
        
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
//            customNavigationBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: (77/932))
            customNavigationBar.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        customNavigationBar.addSubview(cancelButton)
        customNavigationBar.addSubview(captureOptionButton)
        customNavigationBar.addSubview(flashButton2)
        customNavigationBar.addSubview(autoScanButton2)
        customNavigationBar.addSubview(doneButton)
        
        let cancelButtonConstrants = [
            cancelButton.centerYAnchor.constraint(equalTo: customNavigationBar.centerYAnchor),
            cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor),
            cancelButton.widthAnchor.constraint(equalTo: customNavigationBar.widthAnchor, multiplier: (20/430))
        ]
        
        let captureOptionButtonConstrants = [
            captureOptionButton.centerYAnchor.constraint(equalTo: customNavigationBar.centerYAnchor),
            captureOptionButton.heightAnchor.constraint(equalTo: captureOptionButton.widthAnchor),
            captureOptionButton.widthAnchor.constraint(equalTo: customNavigationBar.widthAnchor, multiplier: (20/430))
        ]
        
        let flashButton2Constrants = [
            flashButton2.centerYAnchor.constraint(equalTo: customNavigationBar.centerYAnchor),
            flashButton2.heightAnchor.constraint(equalTo: flashButton2.widthAnchor),
            flashButton2.widthAnchor.constraint(equalTo: customNavigationBar.widthAnchor, multiplier: (20/430))
        ]
        
        let autoScanButton2Constrants = [
            autoScanButton2.centerYAnchor.constraint(equalTo: customNavigationBar.centerYAnchor),
            autoScanButton2.heightAnchor.constraint(equalTo: customNavigationBar.heightAnchor, multiplier: (30/60)),
            autoScanButton2.widthAnchor.constraint(equalTo: customNavigationBar.widthAnchor, multiplier: (184/430))
            //430 -(15+20+20+20+25+20+25+""+35+46+20) = 184
        ]
        
        let doneButtonConstrants = [
            doneButton.centerYAnchor.constraint(equalTo: customNavigationBar.centerYAnchor),
            doneButton.heightAnchor.constraint(equalTo: customNavigationBar.heightAnchor, multiplier: (30/60)),
            doneButton.widthAnchor.constraint(equalTo: customNavigationBar.widthAnchor, multiplier: (46/430))
        ]
        
//        autoScanButton2.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        autoScanButton2.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        NSLayoutConstraint.activate(customNavigationBarConstraints + cancelButtonConstrants + captureOptionButtonConstrants + flashButton2Constrants + autoScanButton2Constrants + doneButtonConstrants)
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
            batchShowView.heightAnchor.constraint(equalTo: lowerView.heightAnchor, multiplier: (77/176)),
            batchShowView.widthAnchor.constraint(equalTo: batchShowView.heightAnchor)
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
