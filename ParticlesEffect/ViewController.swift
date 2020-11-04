//
//  ViewController.swift
//  Particles Effect Test
//
//  Created by Haruko Okada on 10/8/20.
//

import UIKit
import AVFoundation
import SpriteKit
import QuartzCore


class ViewController: UIViewController {

    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?

    
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func fireButtonTapped(_ sender: Any) {
        createFire()
    }
    
    
    @IBAction func smokeButtonTapped(_ sender: Any) {
        createSmoke()
    }
    
    
//    @IBAction func confettiButtonTapped(_ sender: Any) {
//        createConfetti()
//    }
    
//    @IBAction func resetButtonTapped(_ sender: Any) {
//        fire.lifetime = 0
//        smoke.lifetime = 0
//        //confetti.birthRate = 0
//    }
    
    
    func createFire() {
        let fireEmitter = CAEmitterLayer()
        fireEmitter.emitterPosition = CGPoint(x: 200, y: 500)
        fireEmitter.emitterSize = CGSize(width: 150, height: 10);
        fireEmitter.renderMode = CAEmitterLayerRenderMode.additive;
        fireEmitter.emitterShape = CAEmitterLayerEmitterShape.line
        fireEmitter.emitterCells = [createFireCell()];

        self.view.layer.addSublayer(fireEmitter)
    }
    

    let fire = CAEmitterCell()
    func createFireCell() -> CAEmitterCell {
        fire.alphaSpeed = -0.3
        fire.birthRate = 600
        fire.lifetime = 60.0
        fire.lifetimeRange = 0.5
        fire.color = UIColor (red: 0.8, green: 0.4, blue: 0.2, alpha: 0.6).cgColor
        fire.contents = UIImage(named: "fire")?.cgImage
        fire.emissionLongitude = CGFloat(Double.pi)
        fire.velocity = 80
        fire.velocityRange = 5
        fire.emissionRange = 0.5
        fire.yAcceleration = -200
        fire.scaleSpeed = 0.3
        return fire
    }



    func  createSmoke() {
        let smokeEmitter = CAEmitterLayer()
        smokeEmitter.emitterPosition = CGPoint(x: view.center.x, y: view.center.y)
        //smokeEmitter.emitterSize = CGSize(width: 50, height: 50)
        //smokeEmitter.renderMode = CAEmitterLayerRenderMode.additive
        //smokeEmitter.emitterShape = CAEmitterLayerEmitterShape.line
        smokeEmitter.emitterCells = [createSmokeCell()];

        self.view.layer.addSublayer(smokeEmitter)
    }

    let smoke = CAEmitterCell()
    func createSmokeCell() -> CAEmitterCell {
        smoke.birthRate = 20
        smoke.lifetime = 10
        //smoke.lifetimeRange = 10
        smoke.contents = UIImage(named: "smoke")?.cgImage
        //smoke.emissionLongitude = CGFloat(Double.pi)
        smoke.velocity = 80
        //smoke.scale = 0.1
        //smoke.velocityRange = 5
        smoke.emissionRange =  CGFloat.pi * 2.0
       // smoke.yAcceleration = -200
       // smoke.scaleSpeed = 0.3

        return smoke
    }
    
    
    func createConfetti() {
        let confettiEmitter = CAEmitterLayer()

        confettiEmitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
        confettiEmitter.emitterShape = .line
        confettiEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)

        let red = makeEmitterCell(color: UIColor.red)
        let green = makeEmitterCell(color: UIColor.green)
        let blue = makeEmitterCell(color: UIColor.blue)

        confettiEmitter.emitterCells = [red, green, blue]

        view.layer.addSublayer(confettiEmitter)
    }
    
    //let confetti = CAEmitterCell()
    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
       let confetti = CAEmitterCell()
        confetti.birthRate = 10
        confetti.lifetime = 7.0
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = 200
        confetti.velocityRange = 50
        confetti.emissionLongitude = CGFloat.pi
        confetti.emissionRange = CGFloat.pi / 4
        confetti.spin = 2
        confetti.spinRange = 3
        confetti.scaleRange = 0.5
        confetti.scaleSpeed = -0.05

        confetti.contents = UIImage(named: "confetti")?.cgImage
        return confetti
    }

}

//MARK: カメラ設定メソッド
extension ViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                innerCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                mainCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    

    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }

    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
 
}

