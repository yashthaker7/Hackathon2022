//
//  CameraController.swift
//  WakandaApp
//
//  Created by SOTSYS302 on 02/04/22.
//

import UIKit

class BaseViewController: UIViewController {
    
    lazy var renderView: RenderView = {
        let renderView = RenderView()
        renderView.frame = self.view.frame
        return renderView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(renderView, at: 0)
    }
}


class CameraController: BaseViewController, CameraDelegate {
    
    @IBOutlet weak var flashBtn: UIButton!
    
    var camera: Camera!
    
    lazy var imagePicker: TYImagePicker = {
        let imagePicker = TYImagePicker()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        addAppStateObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        camera.startCapture()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        camera.stopCapture()
    }
    
    private func setupCamera(_ location: PhysicalCameraLocation = .backFacing) {
        do {
            camera = try Camera(sessionPreset: .vga640x480, location: location)
            camera.delegate = self
        } catch {
            print("Could not initialize camera.")
        }
    }
    
    enum FlashPhotoMode {
        case on
        case off
    }
    var flashPhotoMode = FlashPhotoMode.off
    
    @IBAction func flashBtnAction(_ sender: UIButton) {
        camera.cameraProcessingQueue.async {
            self.flashPhotoMode = (self.flashPhotoMode == .on) ? .off : .on
            let flashPhotoMode = self.flashPhotoMode
            DispatchQueue.main.async {
                switch flashPhotoMode {
                case .on:
                    self.flashBtn.setImage(UIImage(named: "icn_flash_enable"), for: .normal)
                case .off:
                    self.flashBtn.setImage(UIImage(named: "icn_flash"), for: .normal)
                }
            }
            if self.camera.inputCamera.isFlashAvailable {
                if self.flashPhotoMode == .on {
                    try? self.camera.inputCamera.lockForConfiguration()
                    self.camera.inputCamera.torchMode = .on
                    self.camera.inputCamera.unlockForConfiguration()
                } else {
                    try? self.camera.inputCamera.lockForConfiguration()
                    self.camera.inputCamera.torchMode = .off
                    self.camera.inputCamera.unlockForConfiguration()
                }
            }
        }
    }
    
    @IBAction func capureBtnAction(_ sender: UIButton) {
        camera.capureImage { image in
            self.navigateToTextDetectionVC(image)
        }
    }
    
    @IBAction func galleryBtnAction(_ sender: UIButton) {
        camera.stopCapture()
        imagePicker.presentActionSheet(title: nil, message: nil, parent: self)
    }
    
    @IBAction func changeCameraBtnAction(_ sender: UIButton) {
        if camera.location == .backFacing {
            camera.stopCapture()
            setupCamera(.frontFacing)
            flashBtn.isEnabled = false
            flashBtn.setImage(UIImage(named: "icn_flash"), for: .normal)
        } else {
            camera.stopCapture()
            setupCamera(.backFacing)
            flashBtn.isEnabled = true
        }
        camera.startCapture()
    }
    
    func newTexture(texture: Texture) {
        renderView.newTextureAvailable(texture)
    }
    
    override func appEnterBackground(_ notifiaction: Notification) {
        camera.stopCapture()
    }
    
    override func appEnterForeground(_ notifiaction: Notification) {
        camera.startCapture()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    deinit {
        removeAppStateObserver()
        print(identifier, "deinit")
    }
}

extension CameraController: TYImagePickerDelegate {
    
    func imagePicker(_ imagePicker: TYImagePicker, selectedImage: UIImage?) {
        guard let selectedImage = selectedImage else {
            camera.startCapture()
            return
        }
        navigateToTextDetectionVC(selectedImage)
    }
    
    func imagePicker(_ imagePicker: TYImagePicker, videoURL: URL) {
        navigateToTextDetectionForVideoVC(videoURL)
    }
    
    private func navigateToTextDetectionVC(_ image: UIImage) {
        let textDetectionVC: TextDetectionController = UIStoryboard(.main).instantiateVC()
        textDetectionVC.image = image
        navigationController?.pushViewController(textDetectionVC, animated: true)
    }
    
    private func navigateToTextDetectionForVideoVC(_ videoURL: URL) {
        let textDetectionForVideoVC: TextDetectionForVideoController = UIStoryboard(.main).instantiateVC()
        textDetectionForVideoVC.videoUrl = videoURL
        navigationController?.pushViewController(textDetectionForVideoVC, animated: true)
    }

    func cancelButtonTapped(on imagePicker: TYImagePicker) {
        camera.startCapture()
    }
}
