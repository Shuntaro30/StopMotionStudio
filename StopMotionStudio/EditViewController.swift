//
//  EditViewController.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/5/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import QBImagePickerController

final class EditViewController: UIViewController, QBImagePickerControllerDelegate {
    
    @IBOutlet weak var imagesView: UICollectionView!
    @IBOutlet weak var editableView: UICollectionView!
    @IBOutlet weak var firstSecond: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    
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
    var photoOutput = AVCapturePhotoOutput()
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var images = [UIImage]()
    
    var picker = QBImagePickerController()
    
    var isPlay = false
    
    var timer = Timer()
    
    var projectName = ""
    
    var sourceIndexPath = IndexPath(item: 0, section: 0)
    
    var currentIndex = 0
    
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        
        let layout = UICollectionViewFlowLayout()
        var frame = imagesView.frame as CGRect
        layout.itemSize = CGSize(width: view.frame.width, height: frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        imagesView.collectionViewLayout = layout
        imagesView.isHidden = true
        imagesView.isPagingEnabled = true
        
        let layout2 = UICollectionViewFlowLayout()
        frame = editableView.frame as CGRect
        layout2.itemSize = CGSize(width: frame.width / 5, height: frame.height)
        layout2.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout2.scrollDirection = .horizontal
        editableView.collectionViewLayout = layout2
        resetFrame()
        
        scrollView.delegate = self
        
        // 端末回転の通知を設定します。
        let action = #selector(orientationDidChange)
        let center = NotificationCenter.default
        let notification = UIDevice.orientationDidChangeNotification
        center.addObserver(self, selector: action, name: notification, object: nil)
        // 通知センターの受信を登録
        center.addObserver(self, selector: #selector(didEnterBackground), name: .NSExtensionHostDidEnterBackground, object: nil)
        center.addObserver(self, selector: #selector(resignActive), name: .NSExtensionHostWillResignActive, object: nil)
        center.addObserver(self, selector: #selector(signActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func resignActive(_ notification: NSNotification) {
        
    }
    
    @objc func signActive(_ notification: NSNotification) {
        
    }
    
    @objc func didEnterBackground(_ notification: NSNotification) {
        captureSession.stopRunning()
    }
    
    @objc func orientationDidChange(_ notification: NSNotification) {
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    func resetFrame() {
        let frame = imagesView.frame as CGRect
        let editableFrame = editableView.frame as CGRect
        editableView.frame = CGRect(x: view.frame.width / 2 - (frame.width / 5 / 2), y: 0, width: CGFloat(images.count) * frame.width / 5, height: editableFrame.height)
        let editableFrameNew = editableView.frame as CGRect
        scrollView.contentSize = CGSize(width: editableFrameNew.width + editableFrameNew.minX * 2, height: editableFrameNew.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Notifies the view controller that its view is about to be added to a view hierarchy.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSet" {
            let controller = segue.destination as? SettingsViewController
            controller?.projectName = self.projectName
        } else if segue.identifier == "addTitle" {
            let controller = segue.destination as? AddTitleController
            controller?.image = images[currentIndex]
            controller?.index = self.currentIndex
            controller?.preVC = self
        }
    }
    
    @IBAction func showSettings(_: Any) {
        self.performSegue(withIdentifier: "showSet", sender: nil)
    }
    
    @IBAction func chengeEditor(_: Any) {
        print("changeValue!")
        if firstSecond.selectedSegmentIndex == 0 {
            print(true)
            imagesView.isHidden = true
        } else {
            print(false)
            imagesView.isHidden = false
        }
    }
    
    @IBAction func pushCameraButton(_: Any) {
        if self.currentDevice != nil {
            let settings = AVCapturePhotoSettings()
            // フラッシュをオフにする
            settings.flashMode = .off
            // 撮影された画像をdelegateメソッドで処理
            self.photoOutput.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
        }
    }
    
    @IBAction func pickUpPhoto(_: Any) {
        picker.delegate = self
        picker.allowsMultipleSelection = true
        picker.showsNumberOfSelectedAssets = true
        present(picker, animated: true)
    }
    
    func getAssetImage(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 1120, height: 1120), contentMode: .aspectFit, options: option, resultHandler: { (result, info) in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        for asset in assets as! [PHAsset] {
            let image = self.getAssetImage(asset: asset)
            self.images.append(image)
            resetFrame()
            self.editableView.reloadData()
            self.imagesView.reloadData()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 再生/停止
    
    @IBAction func play(_: Any) {
        if !isPlay {
            self.timer = Timer.scheduledTimer(timeInterval: UserDefaults.standard.double(forKey: self.projectName), target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlay = true
        } else {
            timer.invalidate()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlay = false
        }
    }
    
    func play2() {
        if !isPlay {
            self.timer = Timer.scheduledTimer(timeInterval: UserDefaults.standard.double(forKey: self.projectName), target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlay = true
        } else {
            timer.invalidate()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlay = false
        }
    }
    
    // コマを進める（はず）
    @objc func timerUpdate() {
        if currentIndex < images.count {
            imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択した写真を取得する
        let image = info[.originalImage] as! UIImage
        images.append(image)
        self.imagesView.reloadData()
        self.editableView.reloadData()
        resetFrame()
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
    
    //画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: カメラ設定メソッド
extension EditViewController {
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
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            if let currentDevice = self.currentDevice {
                // 指定したデバイスを使用するために入力を初期化
                let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
                // 指定した入力をセッションに追加
                captureSession.addInput(captureDeviceInput)
                // 出力データを受け取るオブジェクトの作成
                photoOutput = AVCapturePhotoOutput()
                // 出力ファイルのフォーマットを指定
                photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                captureSession.addOutput(photoOutput)
            }
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        let orientation = self.appOrientation()
        self.cameraPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue)!
        
        self.cameraPreviewLayer.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer, at: 0)
    }
}

extension EditViewController: AVCapturePhotoCaptureDelegate {
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            guard let image1 = UIImage(data: imageData) else { return }
            let image = UIImage(cgImage: image1.cgImage!, scale: image1.scale, orientation: .up)
            images.append(image)
            self.editableView.insertItems(at: [IndexPath(item: images.count - 1, section: 0)])
            self.imagesView.reloadData()
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            self.resetFrame()
        }
    }
}

extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        sourceIndexPath = indexPath
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = self.images[indexPath.row]
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        sourceIndexPath = indexPath
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = self.images[indexPath.row]
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let indexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        images.insert(images.remove(at: sourceIndexPath.row), at: indexPath.row)
        editableView.moveItem(at: sourceIndexPath, to: indexPath)
        imagesView.moveItem(at: sourceIndexPath, to: indexPath)
        self.resetFrame()
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        // ドラッグ元が自分のアプリかどうかを判断
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resetFrame()
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === imagesView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCell", for: indexPath)
            let imageView = cell.viewWithTag(1) as? UIImageView
            imageView?.image = images[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCell", for: indexPath)
            let imageView = cell.viewWithTag(1) as? UIImageView
            imageView?.image = images[indexPath.row]
            return cell
        }
    }
    
    // メニューを出すよ
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt
        indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        // ①プレビューの定義
        let previewProvider: () -> PreviewViewController = { [unowned self] in
            let controller = PreviewViewController()
            controller.image = self.images[indexPath.row]
            return controller
        }
        
        // ②メニューの定義
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let remove = UIAction(title: "削除...", image: UIImage(systemName: "trash")) { _ in
                self.images.remove(at: indexPath.row)
                self.editableView.deleteItems(at: [indexPath])
                self.imagesView.deleteItems(at: [indexPath])
                self.resetFrame()
            }
            let addText = UIAction(title: "テキストを追加...", image: UIImage(systemName: "trash")) { _ in
                // まずは、同じstororyboard内であることをここで定義します
                let storyboard: UIStoryboard = self.storyboard!
                // ここで移動先のstoryboardを取得
                let controller = storyboard.instantiateViewController(withIdentifier: "addTitle") as! AddTitleController
                // 遷移方法をpopoverにします
                controller.modalPresentationStyle = .popover
                // popoverのアンカーを設定します
                controller.popoverPresentationController?.sourceView = cell
                // 値渡しをします
                controller.image = self.images[indexPath.row]
                controller.index = indexPath.row
                // 遷移
                self.present(controller, animated: true, completion: nil)
            }
            let menu: UIMenu = {
                let share = UIAction(title: "このコマを共有", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    let activityVC = UIActivityViewController(activityItems: [self.images[indexPath.row]], applicationActivities: nil)
                    let sourceView = collectionView.cellForItem(at: indexPath)
                    activityVC.popoverPresentationController?.sourceView = sourceView
                    // UIActivityViewControllerを表示
                    self.present(activityVC, animated: true, completion: nil)
                }
                return UIMenu(title: "その他", image: nil, identifier: nil, children: [share])
            }()
            return UIMenu(title: "編集", image: nil, identifier: nil, children: [remove, /* addText, */ menu])
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider, actionProvider: actionProvider)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === self.scrollView {
            let contentOffset = scrollView.contentOffset
            print("スクロールしたよ contantsOffset.x: \(contentOffset.x)")
            let frame = self.view.frame as CGRect
            self.currentIndex = Int(round(contentOffset.x / (frame.width / 5 + 20)))
            self.imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === self.scrollView {
            let contentOffset = scrollView.contentOffset
            print("スクロールしたよ contantsOffset.x: \(contentOffset.x)")
            let frame = self.view.frame as CGRect
            self.currentIndex = Int(round(contentOffset.x / (frame.width / 5 + 20)))
            self.imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === self.scrollView {
            let contentOffset = scrollView.contentOffset
            print("スクロールしたよ contantsOffset.x: \(contentOffset.x)")
            let frame = self.view.frame as CGRect
            self.currentIndex = Int(round(contentOffset.x / (frame.width / 5 + 20)))
            self.imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
        }
    }

}

extension UIImage {
    
    func rotatedBy(degree: CGFloat) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
}

