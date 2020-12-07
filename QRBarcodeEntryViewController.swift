//
//  QRBarcodeEntryViewController.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 12/3/20.
//

import UIKit
import AVFoundation

protocol MatchableAuthenticatedProtocol {
    func codeWasSuccessfullyMatched(vc: UIViewController, code: String)
    func codeNotFound(vc: UIViewController, code: String)
}

class QRCodeBarcodeEntryViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let videoContainerView = VideoContainerView()
    let flashView = UIView()
    
    var delegate: MatchableAuthenticatedProtocol?
    var foundCount = 0
    
    var matchables = [String]()
    var boxTitle: String = ""
    
    convenience init(matchables: [String], title: String) {
        self.init()
        self.matchables = matchables
        // set(epTitle: PickerStyle.scannerTitle(), epSubTitle: nil) // not used -- no nav bar
    }
    
    deinit {
        self.captureSession = nil
        self.previewLayer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        setupCaptureSession()
        captureSession.startRunning()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        setOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setOrientation()
        view.setNeedsUpdateConstraints()
        view.setNeedsLayout()
        videoContainerView.needsUpdateConstraints()
        videoContainerView.setNeedsLayout()
    }
    
    func setOrientation() {
        var videoOrientation: AVCaptureVideoOrientation!
        let orientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        default:
            videoOrientation = .portrait
            break
        }
        
        previewLayer.connection?.videoOrientation = videoOrientation
        if PickerStyle.scannerCameraFacingPosition() == .front {
            previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
            previewLayer.connection?.isVideoMirrored = false
        }
    }
    
    private func setup() {
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        if #available(iOS 13, *) {
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = .white
            bar.layer.cornerRadius = 2
            bar.layer.masksToBounds = true
            view.addSubview(bar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[bar(100)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["bar": bar]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bar(4)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["bar": bar]))
            view.addConstraint(NSLayoutConstraint(item: bar, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: bar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 12.0))
        } else {
            let cancelButton = UIButton(type: .custom)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
            view.addSubview(cancelButton)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelButton(100)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["cancelButton": cancelButton]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cancelButton(40)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["cancelButton": cancelButton]))
            view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 10.0))
        }
        
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.backgroundColor = .clear
        view.addSubview(videoContainerView)
        view.addConstraint(NSLayoutConstraint(item: videoContainerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: videoContainerView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=40@750)-[anchor(5000@250)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["anchor": videoContainerView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=40@750)-[anchor]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["anchor": videoContainerView]))
        view.addConstraint(NSLayoutConstraint(item: videoContainerView, attribute: .width, relatedBy: .equal, toItem: videoContainerView, attribute: .height, multiplier: 1.0, constant: 0.0))
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = videoContainerView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        videoContainerView.layer.addSublayer(previewLayer)
        videoContainerView.videoLayer = previewLayer
        
        flashView.translatesAutoresizingMaskIntoConstraints = false
        flashView.backgroundColor = .clear
        flashView.layer.borderColor = UIColor.white.cgColor
        flashView.layer.borderWidth = 2
        view.addSubview(flashView)
        view.addConstraint(NSLayoutConstraint(item: flashView, attribute: .centerX, relatedBy: .equal, toItem: videoContainerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: flashView, attribute: .centerY, relatedBy: .equal, toItem: videoContainerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: flashView, attribute: .width, relatedBy: .equal, toItem: videoContainerView, attribute: .width, multiplier: 1.0, constant: 8.0))
        view.addConstraint(NSLayoutConstraint(item: flashView, attribute: .height, relatedBy: .equal, toItem: videoContainerView, attribute: .height, multiplier: 1.0, constant: 8.0))
        view.sendSubviewToBack(flashView)
        
        let label = UILabel()
        label.text = boxTitle
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["label": label]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label(26)]-[flash]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["label": label, "flash": flashView]))
        
    }
    
    @objc func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupCaptureSession() {
        
        let cameraFaceType = PickerStyle.scannerCameraFacingPosition()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraFaceType) else { return } // simulator fails guard
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .code39, .code93, .code128, .code39Mod43]
        } else {
            failed()
            return
        }
    }
}

// MARK: failure/success
extension QRCodeBarcodeEntryViewController {
    
    func failed() {
        captureSession = nil
    }
    
    private func stringIsMatchable(potential: String) -> Bool {
        for string in matchables {
            if string.lowercased().contains(potential.lowercased()) {
                return true
            }   
        }
        
        return false
    }
    
    func found(code potential: String) {
        foundCount += 1
        guard foundCount == 1 else { return }
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard let s = self else { return }
            s.flashView.backgroundColor = .white
        }) { [weak self] (complete) in
            guard let s = self else { return }
            s.flashView.startBlinking(completion: { [weak self] in
                guard let s = self else { return }
                s.flashView.stopBlinking()
                guard s.stringIsMatchable(potential: potential) else {
                    if let d = s.delegate {
                        d.codeNotFound(vc: s, code: potential)
                    }
                    return
                }
                s.delegate?.codeWasSuccessfullyMatched(vc: s, code: potential)
                s.foundCount = 0
            })
        }
    }
}

// MARK: delegate
extension QRCodeBarcodeEntryViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            found(code: stringValue)
        }
    }
}

class VideoContainerView: UIView {
    
    var videoLayer: CALayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let videoLayer = videoLayer else { return }
        videoLayer.frame = self.bounds
    }
}
